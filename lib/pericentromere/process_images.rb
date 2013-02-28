#--
# /* ***** BEGIN LICENSE BLOCK *****
#  * 
#  * Copyright (c) 2013 Colin J. Fuller
#  * 
#  * Permission is hereby granted, free of charge, to any person obtaining a copy
#  * of this software and associated documentation files (the Software), to deal
#  * in the Software without restriction, including without limitation the rights
#  * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  * copies of the Software, and to permit persons to whom the Software is
#  * furnished to do so, subject to the following conditions:
#  * 
#  * The above copyright notice and this permission notice shall be included in
#  * all copies or substantial portions of the Software.
#  * 
#  * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  * SOFTWARE.
#  * 
#  * ***** END LICENSE BLOCK ***** */
#++

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


