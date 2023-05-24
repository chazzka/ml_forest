# frozen_string_literal: true

module Node
  include Helper

  def self.init_from_data(data, forest_helper: Helper, depth: 0, max_depth: Math.log(data.length, 2).ceil)
    if forest_helper.end_condition(data, depth, max_depth)
      return OutNode.new(data, forest_helper.out_node_depth_adjust(data, depth))
    end

    decision_fun = forest_helper.get_initial_decision(data)
    node_groups = forest_helper.get_node_groups(data, decision_fun)

    InNode.new(
      node_groups.transform_values do |group|
        init_from_data(group, forest_helper: forest_helper, depth: forest_helper.depth_transform(group, depth), max_depth: max_depth)
      end,
      decision_fun
    )
  end

  def self.evaluate_path_length(node, element, forest_helper: Helper)
    return node if node.is_a?(OutNode)

    next_node_branch = node.decision.call(element)
    evaluate_path_length(node.branches[next_node_branch], element, forest_helper: forest_helper)
  end

  OutNode = Data.define(:data, :depth) do
    def to_a
      data
    end
  end

  InNode = Data.define(:branches, :decision) do
    def to_a
      branches.values.map(&:to_a)
    end

    def to_h
      branches.values.map(&:to_h)
    end
  end
end