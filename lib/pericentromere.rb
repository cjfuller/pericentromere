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
require 'trollop'

require 'pericentromere/process_images'

module Pericentromere
	
	DEF_MAX_SIZE = 50
	DEF_MIN_SIZE = 5
	DEF_INTERCEN_DIST = 10.0
	DEF_REGION_SIZE = 10.0
	DEF_FILTER_CH = 0
	DEF_PERICENTROMERE_CH = 1
	DEF_MARKER_CH = 3

	def self.run

		opts = Trollop::options do

			opt :max_size, "Maximum centromere size (pixels)", type: :integer, default: DEF_MAX_SIZE
			opt :min_size, "Minimum centromere size (pixels)", type: :integer, default: DEF_MIN_SIZE
			opt :max_intercentromere_dist, "Maximum allowable distance between a centromere pair (pixels)", type: :float, default: DEF_INTERCEN_DIST
			opt :pericentromere_region_size, "Size of the region around the centromere used for finding the pericentromere (pixels)", type: :float, default: DEF_REGION_SIZE
			opt :marker_channel, "Centromere marker channel (0-indexed)", type: :integer, default: DEF_MARKER_CH
			opt :filter_channel, "Channel on which to filter centromeres (DNA staining; 0-indexed)", type: :integer, default: DEF_FILTER_CH
			opt :pericentromere_channel, "Pericentromere marker channel (0-indexed)", type: :integer, default: DEF_PERICENTROMERE_CH
			opt :dir, "Directory to process (specify either this or file option)", type: :string
			opt :file, "File to process (specify either this or dir option)", type: :string

		end

		if opts[:dir] then 

			process_image_directory(opts[:dir], opts)

		elsif opts[:file] then

			process_single_image(opts[:file], opts)

		end

	end

end
