module GUITestRunner
using Tk
using TestRunner

include("Widgets.jl")

import TestRunner: TestStructureNode, FactsCollectionNode, FactNode, children, ContextNode
import Tk:Tk_Frame, Tk_Labelframe

export start_test_runner

source_path =  @__FILE__() |> dirname
hidden_tests_groups_ids = Int[]
get_file_name = ()->""

start_test_runner() = create_main_window()

browse_dir_callback!(file_name_input::Tk_Widget) = set_value(file_name_input, GetOpenFile())

function load_tests_button_callback!(frame)
  tests_structure = get_file_name() |> get_tests_structure |> children
  process_tests_callback!(frame, tests_structure)
end

function run_tests_button_callback!(frame)
  tests_structure = get_file_name() |> run_all_tests |> children
  process_tests_callback!(frame, tests_structure)
end

function process_tests_callback!(frame::Tk_Frame, tests_structure::Vector{TestStructureNode})
  clear_current_tests!(frame)
  try
    display_all_tests!(frame, tests_structure)
  catch
    Messagebox(frame, "Uncorrect file with tests!")
  end
end

function tests_header_callback!(frame::Tk_Frame, test_node::TestStructureNode, tests_structure::Vector{TestStructureNode})
  global hidden_tests_groups_ids
  if test_node.line in hidden_tests_groups_ids
    hidden_tests_groups_ids = filter(x -> x != line(test_node), hidden_tests_groups_ids)
  else
    push!(hidden_tests_groups_ids, line(test_node))
  end
  clear_all_tests!(frame)
  display_all_tests!(frame, tests_structure)
end

function single_test_callback!(frame::Tk_Frame, test_node::TestStructureNode)
  clear_all_test_details!(frame)
  test_details = details(test_node)
  display_test_details!(frame, test_details)
end

line_number_button_callback(test_node::TestStructureNode, tests_file_name::AbstractString) =
  @async run(`$source_path/lineNumberOnClick.sh $(test_node.line) $tests_file_name`)

open_details_button_callback(test_details::AbstractString) =  create_new_window(test_details, 400, 350)

function clear_current_tests!(frame::Tk_Frame)
  global hidden_tests_groups_ids
  empty!(hidden_tests_groups_ids)
  clear_all_tests!(frame)
  clear_all_test_details!(frame)
end

function display_all_tests!(frame::Tk_Frame, tests_structure::Vector{TestStructureNode})
  for node in tests_structure
    display_nodes!(frame, node, tests_structure)
  end
end

function display_nodes!(frame::Tk_Frame, test_node::TestStructureNode, tests_structure::Vector{TestStructureNode}, nesting_level::Int=0)
  nesting_level = draw_node!(frame, tests_structure, test_node, nesting_level)

  global hidden_tests_groups_ids
  line(test_node) in hidden_tests_groups_ids && return
  for child in TestRunner.children(test_node)
    display_nodes!(frame, child, tests_structure, nesting_level)
  end
end

function draw_node!(frame::Tk_Frame, tests_structure::Vector{TestStructureNode}, test_node::TestStructureNode,  nesting_level::Int)
  nesting_level, node_label = get_node_label!(frame, tests_structure, test_node, nesting_level)
  padding = (nesting_level-1)*15
  pack(node_label, fill="x",padx="$padding 0")
  nesting_level
end

function display_test_details!(frame::Tk_Frame, test_details::AbstractString)
  test_details == "" && return
  create_open_details_button!(frame, test_details)
  create_details_textbox!(frame, test_details)
end

get_frame_for_tests(frame::Tk_Frame) = filter(x->isa(x, Tk.Tk_Labelframe), frame.children)[1]

get_frame_for_test_details(frame::Tk_Frame) = filter(x->isa(x, Tk.Tk_Labelframe), frame.children)[2]

clear_all_tests!(frame::Tk_Frame) = clear_all_children!(get_frame_for_tests(frame))

clear_all_test_details!(frame::Tk_Frame) = clear_all_children!(get_frame_for_test_details(frame))

function clear_all_children!(frame::Union{Tk_Frame, Tk_Labelframe, Tk.Tk_Text})
  for child in frame.children
    child |> forget
  end
  empty!(frame.children)
end

end # module
