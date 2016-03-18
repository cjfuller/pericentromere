require 'rimageanalysistools'
require 'rimageanalysistools/get_image'
require 'rimageanalysistools/create_parameters'
require 'rimageanalysistools/simple_output'
require 'pericentromere/find_centromeres'
require 'pericentromere/resegment_within_regions'
require 'pericentromere/quantification'

module Pericentromere

	def self.process_single_image(fn, params_hash)

		params = RImageAnalysisTools.create_parameter_dictionary(params_hash)

		multichannel_image = RImageAnalysisTools.get_image(fn)

		mask = Pericentromere.find_centromeres(multichannel_image, params)

		circ_mask = Pericentromere.circularize_regions(mask, params_hash[:pericentromere_region_size].to_f)

		reseg_mask = Pericentromere.resegment_within_regions(circ_mask, multichannel_image, params_hash[:pericentromere_channel])

		quant = Pericentromere.quantify(reseg_mask, multichannel_image)

		RImageAnalysisTools.handle_output(fn, reseg_mask, quant)

	end

	def self.process_image_directory(dirname, params_hash)

		Dir.foreach(dirname) do |fn|

			complete = File.expand_path(fn, dirname)

			if File.file?(complete) then

				process_single_image(complete, params_hash)

			end

		end

	end

end


