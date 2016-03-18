require 'rimageanalysistools'
require 'rimageanalysistools/create_parameters'
require 'rimageanalysistools/method/centromere_finding_method'
require 'rimageanalysistools/centroids'
require 'rimageanalysistools/get_filter'


require 'pericentromere/centromere_pairing'

java_import Java::edu.stanford.cfuller.imageanalysistools.image.ImageSet
java_import Java::edu.stanford.cfuller.imageanalysistools.meta.parameters.ParameterDictionary
java_import Java::edu.stanford.cfuller.imageanalysistools.image.ImageFactory

module Pericentromere

	def self.basic_centromere_finding(im, params)

		is = ImageSet.new(params)

		is.addImageWithImage(im)

		is.setMarkerImage(0)

		cfm = RImageAnalysisTools::CentromereFindingMethod.new

		cfm.parameters= params
		cfm.input_images = is

		cfm.go

	end

	def self.filter_by_pairing(mask, params)

		cp = Pericentromere::CentromerePairing.new

		cens = RImageAnalysisTools::Centroids.calculate_centroids_2d(mask)

		pairs = cp.make_centromere_pairs(params, cens)

		paired_mask = ImageFactory.createWritable(mask)

		cp.remove_unpaired_centromeres(pairs, paired_mask)

		lf = RImageAnalysisTools.get_filter :LabelFilter

		lf.apply(paired_mask)

		paired_mask

	end

	def self.filter_by_other_channel(mask, im, params)

		im = ImageFactory.createWritable(im)
		mask = ImageFactory.createWritable(mask)

		mstf = RImageAnalysisTools.get_filter :MaximumSeparabilityThresholdingFilter
		lf = RImageAnalysisTools.get_filter :LabelFilter
		mf = RImageAnalysisTools.get_filter :MaskFilter

		mstf.apply(im)
		lf.apply(im)

		mf.setReferenceImage(im)

		mf.apply(mask)

		lf.apply(mask)

		mask

	end


	def self.find_centromeres(im, params)

		channels = im.splitChannels

		marker = channels.get(params[:marker_channel].to_i)
		filter_im = channels.get(params[:filter_channel].to_i)

		mask = basic_centromere_finding(marker, params)

		paired_mask = filter_by_pairing(mask, params)

		filtered_mask = filter_by_other_channel(paired_mask, filter_im, params)

		paired_mask = filter_by_pairing(filtered_mask, params)

	end

end


