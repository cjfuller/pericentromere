require 'find_beads'
require 'rimageanalysistools/get_filter'
require 'rimageanalysistools/graythresh'

java_import Java::edu.stanford.cfuller.imageanalysistools.image.ImageFactory
java_import Java::edu.stanford.cfuller.imageanalysistools.image.ImageCoordinate


module Pericentromere

  def self.circularize_regions(centromere_mask, region_radius)

		final_mask = ImageFactory.create_writable(centromere_mask)

		final_mask.each { |ic| final_mask[ic] = 0 }

		cens = FindBeads.centroids(centromere_mask)

		final_mask.each do |ic|

      x = ic[:x]
      y = ic[:y]

      cens.each_key do |k|

        if Math.hypot(cens[k][0] - x, cens[k][1] - y) <= region_radius then

          final_mask[ic] = k

        end

      end

    end

    final_mask.each do |ic|

      next unless final_mask[ic] > 0

      if FindBeads.is_on_voronoi_border?(cens.values, ic) then

      	final_mask[ic] = 0

      end

    end

    lf = RImageAnalysisTools.get_filter :LabelFilter

    lf.apply(final_mask)

    final_mask

  end

	def self.resegment_within_regions(centromere_mask, original_image, resegmentation_channel)

		pixels_by_region = {}

		icclone = ImageCoordinate.createCoordXYZCT(0,0,0,0,0)

		centromere_mask.each do |ic|

			value = centromere_mask[ic]

			next unless value > 0

			pixels_by_region[value] = [] unless pixels_by_region[value]

			icclone.setCoord(ic)

			icclone[:c]= resegmentation_channel

			pixels_by_region[value] << original_image[icclone]

		end


		thresholds_by_region = {}

		pixels_by_region.each do |region_id, values|

			thresholds_by_region[region_id] = RImageAnalysisTools.graythresh(values)

		end

		output_mask = ImageFactory.create_writable(centromere_mask)

		centromere_mask.each do |ic|

			value = centromere_mask[ic]

			next unless value > 0

			icclone.setCoord(ic)
			icclone[:c] = resegmentation_channel

			if original_image[icclone] <= thresholds_by_region[value] then

				output_mask[ic] = 0

			end

		end

		icclone.recycle

		output_mask

	end

end
