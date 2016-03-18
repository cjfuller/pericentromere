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
