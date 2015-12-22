module GUITestRunner
using Tk
using TestRunner

import TestRunner: TestStructureNode, FactsCollectionNode, FactNode
import Tk:Tk_Frame, Tk_Labelframe

export start_test_runner

function start_test_runner()
  hidden_tests_groups_names = AbstractString[]

  display_test = (frame, node, testStructure) -> display_nodes(frame, node, testStructure, hidden_tests_groups_names)
  display_tests = (frame, tests_func) -> display_all_tests(frame, tests_func(), display_test)
  clear_tests = (frame)->clear_current_tests(frame, hidden_tests_groups_names)

  tests_structure_func = (file_name_func) -> get_tests_structure(file_name_func())
  tests_results_func = (file_name_func) -> run_all_tests(file_name_func())

  load_tests_button_callback = (frame, file_name_function)-> process_tests_callback(frame, file_name_function, tests_structure_func, display_tests, clear_tests)
  run_tests_button_callback = (frame, file_name_function) -> process_tests_callback(frame, file_name_function, tests_results_func, display_tests, clear_tests)

  create_main_window(load_tests_button_callback, run_tests_button_callback)
end

function create_main_window(load_tests_button_callback::Function, run_tests_button_callback::Function)
  window = Toplevel("Julia Test Runner", 350, 600)
  pack_stop_propagate(window)

  frame = Frame(window, padding = [3,3,2,2])
  pack(frame, expand = true, fill = "both")

  file_name_input = Entry(frame)
  pack(file_name_input)
  file_name_function = () -> get_value(file_name_input)
  #grid(file_name_input, 1, 1)

  #set values for testing
  set_value(file_name_input, "/home/student/.julia/v0.4/GUITestRunner/test/sampleTests.jl")

  browse_dir_button = Button(frame, "...")
  pack(browse_dir_button)
  #grid(browse_dir_button, 1, 3)
  bind(browse_dir_button, "command", _->browse_dir_callback(file_name_input))

  load_tests_button = Button(frame, "Load tests!")
  pack(load_tests_button)
  bind(load_tests_button, "command") do _
    load_tests_button_callback(frame, file_name_function)
  end

  run_tests_button = Button(frame, "Run tests!")
  pack(run_tests_button)
  bind(run_tests_button, "command") do _
    run_tests_button_callback(frame, file_name_function)
  end

  tests_list_frame = Labelframe(frame, "Tests")
  pack(tests_list_frame)

  test_details_frame = Labelframe(frame, "Test result details")
  pack(test_details_frame)

  frame
end

function browse_dir_callback(file_name_input::Tk_Widget)
  choice = GetOpenFile()
  set_value(file_name_input, choice)
end

function process_tests_callback(frame::Tk_Frame, file_name_func::Function, processing_func::Function, display_tests::Function, clear_tests::Function)
  clear_tests(frame)
  display_tests(frame, () -> processing_func(file_name_func))
end

function clear_current_tests(frame::Tk_Frame, hidden_tests_groups_names::Vector{AbstractString})
  empty!(hidden_tests_groups_names)
  clear_all_tests(frame)
  clear_all_test_details(frame)
end

function tests_header_callback(frame::Tk_Frame, testNode::TestStructureNode, tests_structure::Vector{TestStructureNode}, hidden_tests_groups_names::Vector{AbstractString})
  if testNode.name in hidden_tests_groups_names
    hidden_tests_groups_names = filter(x -> x != testNode.name, hidden_tests_groups_names)
  else
    push!(hidden_tests_groups_names, testNode.name)
  end
  clear_all_tests(frame)
  display_all_tests(frame, tests_structure, (_frame, node, testStructure)-> display_nodes(_frame, node, testStructure, hidden_tests_groups_names))# tu brakuje labela dla detailsów
end

function single_test_callback(frame::Tk_Frame, testNode::TestStructureNode)
  clear_all_test_details(frame)
  test_details = get(testNode.details, "")
  display_test_details(frame, test_details)
end

function display_test_details(frame::Tk_Frame, test_details::AbstractString)
  label  = Label(get_frame_for_test_details(frame), test_details)
  pack(label)
end

function get_image(result::Symbol)
  if result == :question
    img_name = "question.png"
  elseif result == :failure
    img_name = "failure.png"
  elseif result == :success
    img_name = "success.png"
  else
    error("Image not specified for this type of $result.")
  end

  img_path = Pkg.dir("GUITestRunner", "images", img_name)
  Image(img_path)
end

function get_result(testNode::FactNode)
  if isnull(result(testNode))
   :question
  else
    get(result(testNode)) ? :success : :failure
  end
end

function draw_node(frame::Tk_Frame, testNode::TestStructureNode, tests_structure::Vector{TestStructureNode}, hidden_tests_groups_names::Vector{AbstractString})
  frame_for_tests = get_frame_for_tests(frame)
  button_text = testNode.name == "" ? "Tests group" : testNode.name
  if isa(testNode, TestRunner.FactNode)
    test_result = get_result(testNode)
    img = get_image(test_result)
    node_button = Button(frame_for_tests, text="yolo", image=img, compound="left")
    bind(node_button, "command") do _
      single_test_callback(frame, testNode)
    end
  else
    node_button = Button(frame_for_tests, text="yolo2", compound="left")
    bind(node_button, "command") do _
      tests_header_callback(frame, testNode, tests_structure, hidden_tests_groups_names)
    end
  end
  pack(node_button)
end

function display_nodes(frame::Tk_Frame, testNode::TestStructureNode, tests_structure::Vector{TestStructureNode}, hidden_tests_groups_names::Vector{AbstractString})
  draw_node(frame, testNode, tests_structure, hidden_tests_groups_names)
  if !(testNode.name in hidden_tests_groups_names)
    map(child -> display_nodes(frame, child, tests_structure, hidden_tests_groups_names), TestRunner.children(testNode))
  end
end

function display_all_tests(frame::Tk_Frame, testStructure::Vector{TestStructureNode}, display_test::Function)
  for node in testStructure
    display_test(frame, node, testStructure)
  end
end

get_frame_for_tests(frame::Tk_Frame) = filter(x->isa(x, Tk.Tk_Labelframe), frame.children)[1]

get_frame_for_test_details(frame::Tk_Frame) = filter(x->isa(x, Tk.Tk_Labelframe), frame.children)[2]

function clear_all_children(frame::Union{Tk_Frame, Tk_Labelframe})
  map(child->forget(child), frame.children)
  empty!(frame.children)
end

clear_all_tests(frame::Tk_Frame) = clear_all_children(get_frame_for_tests(frame))

clear_all_test_details(frame::Tk_Frame) = clear_all_children(get_frame_for_test_details(frame))

end # module
