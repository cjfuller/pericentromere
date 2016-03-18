java_import Java::edu.stanford.cfuller.imageanalysistools.image.ImageSet
java_import Java::edu.stanford.cfuller.imageanalysistools.metric.IntensityPerPixelMetric

require 'rimageanalysistools/create_parameters'

module Pericentromere

	def self.quantify(mask, multichannel_image)

		ippm = IntensityPerPixelMetric.new

		is = ImageSet.new(RImageAnalysisTools.create_parameter_dictionary({}))

		split = multichannel_image.splitChannels

		split.each do |im|

			is.addImageWithImage(im)

		end

		ippm.quantify(mask, is)

	end

end

