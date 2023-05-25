# frozen_string_literal: true

require_relative "adamforest/version"
require_relative "adamforest/services/helper"
require_relative "adamforest/services/helper_mock"
require_relative "adamforest/node"

module AdamForest
  include Node
  include Helper

  class Forest
    attr_reader :trees, :forest_helper, :batch_size

    def initialize(
      data,
      trees_count: 100,
      forest_helper: Helper,
      batch_size: data.length < 128 ? data.length : 128,
      max_depth: Math.log(batch_size, 2).ceil,
      random: Random
    )
      # create more trees and return as array
      @forest_helper = forest_helper
      @trees = trees_count.times.map { |_| Node.init_from_data(data.sample(batch_size, random: random), forest_helper: @forest_helper, max_depth: max_depth) }
      @batch_size = batch_size
    end

    def evaluate_forest(element)
      trees.map { |tree| Node.evaluate_path_length(tree, element, forest_helper: @forest_helper) }
    end

    def evaluate_forest_return_depths(element)
      evaluate_forest(element).map(&:depth)
    end
  end
end
