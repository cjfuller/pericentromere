require 'rimageanalysistools'
require 'rimageanalysistools/drawing'

require 'set'
require 'matrix'

module Pericentromere

	class CentromerePairing

    ##
    # Generates a list of centromere pairs based upon a nearest-neighbor criterion:
    # if a centromere has only one other centromere within a specified distance
    # cutoff (and likewise for the other centromere), then they are paired.
    #
    # The distance cutoff (in pixels) is specified by the parameter
    # max_intercentromere_dist.
    #
    # @param [ParameterDictionary] p   a ParameterDictionary object that minimally
    #                                  contains the key max_intercentromere_dist
    #                                  (a hash containing this key is ok too)
    #
    # @param [Hash] centroids          a hash with one key per region label
    #                                  with each value the (x,y) coordinates
    #                                  of the centroid of that region stored
    #                                  in an array.
    #
    # @return [Array] an array containing an array for each pair that contains that
    #                 pair's labels.
    #
    def make_centromere_pairs(p, centroids)

    	labels = centroids.keys.sort

    	max_dist = p[:max_intercentromere_dist].to_f

    	distance_matrix = Matrix.build(labels.size, labels.size) do |r,c|

    		c0 = centroids[labels[r]]
    		c1 = centroids[labels[c]]

    		if (not ( r == c )) and Math.hypot(c0[0]-c1[0], c0[1]-c1[1]) < max_dist then
    			1
    		else
    			0
    		end

    	end

    	pairs = []

    	blacklist = Set.new

    	distance_matrix.row_size.times do |i|

    		row = distance_matrix.row(i)

    		sum = row.reduce(0.0) { |a,e| a + e }

    		if sum > 1 then

    			blacklist.add(i)

    		end

    	end

    	distance_matrix.row_size.times do |i|

    		next if blacklist.include?(i)

    		(i+1).upto(distance_matrix.row(i).size - 1) do |j|

    			if (not blacklist.include?(j)) and distance_matrix[i,j] > 0 then

    				pairs << [labels[i],labels[j]]

    			end

    		end

    	end

    	pairs

    end


    ##
    # Removes any centromeres that are not paired from a mask.
    #
    # @param [Array] pairs An array containing the pairs, for instance from the output of #make_centromere_pairs
    # @param [WritableImage] mask The image mask from which the centromeres will be removed.
    #
    # @return [void]
    #
    def remove_unpaired_centromeres(pairs, mask)

    	paired_lookup = {}

    	mask.each do |ic|

    		value = mask.getValue(ic)

    		next if value == 0

    		is_paired = paired_lookup[value]

    		if is_paired.nil? then

    			is_paired = pairs.any? { |p| p.include? value }

    			paired_lookup[value] = is_paired

    		end

    		mask[ic]= 0 unless is_paired

    	end

    end


    ##
    # Makes intensity measurements on centromere pairs and adds them to a
    # quantification object.  For each member of a pair, adds two measurements:
    # a pair id number, and the difference between the intensity of that member and
    # the mean of the pair.
    #
    # @param [Quantification] q  The quantification object to which the measurements
    #                            will be added.  Should also contain an intensity
    #                            measurement for each region named by the
    #                            measurement_name parameter
    # @param [Array] pairs       Contains a series of two-element arrays, each of
    #                            which contains the labels of paired centromeres.
    # @param [String] measurement_name  The name of the intensity meausrement for
    #                            individual centromeres that is already in the
    #                            quantification and off of which the pair measurements
    #                            will be based.
    # @return [Array]            An array, containing another array for each pair,
    #                            which will have the two labels for each pair, and the
    #                            two intensities for each pair (not diff. from mean).
    #
    def make_pair_measurements(q, pairs, measurement_name)

    	pair_measurements = []

    	pairs.each_with_index do |pair, i|

    		l1 = pair[0]
    		l2 = pair[1]

    		m = Measurement.new(true, l1, i+1, "pair_id", Measurement::TYPE_GROUPING, "")
    		q.addMeasurement(m)
    		m = Measurement.new(true, l2, i+1, "pair_id", Measurement::TYPE_GROUPING, "")
    		q.addMeasurement(m)

    		meas_list_l1 = q.getAllMeasurementsForRegion(l1)
    		meas_list_l2 = q.getAllMeasurementsForRegion(l2)

    		i1 = nil
    		i2 = nil

    		s1 = nil
    		s2 = nil

    		meas_list_l1.each do |meas|

    			if meas.getMeasurementName == measurement_name then
    				i1 = meas.getMeasurement
    			end

    			if meas.getMeasurementType == Measurement::TYPE_SIZE then
    				s1 = meas.getMeasurement
    			end

    		end

    		meas_list_l2.each do |meas|

    			if meas.getMeasurementName == measurement_name then
    				i2 = meas.getMeasurement
    			end

    			if meas.getMeasurementType == Measurement::TYPE_SIZE then
    				s2 = meas.getMeasurement
    			end

    		end

    		i1*= s1
    		i2*= s2

    		imean = (i1+i2)/2.0

    		m = Measurement.new(true, l1, i1-imean, "difference_from_pair_mean", Measurement::TYPE_INTENSITY, "")
    		q.addMeasurement(m)
    		m = Measurement.new(true, l2, i2-imean, "difference_from_pair_mean", Measurement::TYPE_INTENSITY, "")
    		q.addMeasurement(m)

    		pair_measurements << [l1, l2, i1, i2]

    	end

    	pair_measurements

    end

    ##
    # Draws an ellipse on the supplied mask around each pair of centromeres.
    #
    # @param [Hash] centroids          a hash with one key per region label
    #                                  with each value the (x,y) coordinates
    #                                  of the centroid of that region stored
    #                                  in an array.
    # @param [Array] pairs             an array containing one array for each pair
    #                                  of centromeres that itself contains the two
    #                                  labels for that pair
    # @param [WritableImage] mask      a WritableImage in which each region's
    #                                  greylevel is its region label; ellipses
    #                                  will be drawn on this mask.
    #
    def draw_centromere_pairs(centroids, pairs, mask)

    	dr = RImageAnalysisTools::Drawing.new

    	pairs.each do |pair|

    		l1 = pair[0]
    		l2 = pair[1]

    		dr.draw_shape(mask, [centroids[l1], centroids[l2]], :ellipse, 10)

    	end

    	nil

    end

  end

end
