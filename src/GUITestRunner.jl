module GUITestRunner
using Tk
using TestRunner

import TestRunner: TestStructureNode, FactsCollectionNode, FactNode
import Tk:Tk_Frame, Tk_Labelframe

export start_test_runner

source_path =  @__FILE__() |> dirname

function start_test_runner()
  hidden_tests_groups_ids = Int[]

  display_test(frame, node, file_name_func, testStructure) = display_nodes(frame, node, testStructure, file_name_func, hidden_tests_groups_ids)
  display_tests(frame, tests_func, file_name_func) = display_all_tests(frame, tests_func(), file_name_func, display_test)
  clear_tests(frame) = clear_current_tests(frame, hidden_tests_groups_ids)

  tests_structure_func(file_name_func) = get_tests_structure(file_name_func())
  tests_results_func(file_name_func) = run_all_tests(file_name_func())

  load_tests_button_callback(frame, file_name_function) = process_tests_callback(frame, file_name_function, tests_structure_func, display_tests, clear_tests)
  run_tests_button_callback(frame, file_name_function) = process_tests_callback(frame, file_name_function, tests_results_func, display_tests, clear_tests)

  create_main_window(load_tests_button_callback, run_tests_button_callback)
end

function create_main_window(load_tests_button_callback::Function, run_tests_button_callback::Function)
  window = Toplevel("Julia Test Runner", 350, 600)
  pack_stop_propagate(window)

  frame = Frame(window, padding = [3,3,2,2])
  pack(frame, expand = true, fill = "both")

  file_name_input = Entry(frame)
  file_name_function = () -> get_value(file_name_input)

  pack(file_name_input, fill="both")

  #set values for testing
  set_value(file_name_input, "/home/student/.julia/v0.4/GUITestRunner/test/sampleTests.jl")

  browse_dir_button = Button(frame, "Choose file")
  pack(browse_dir_button, fill="both")
  bind(browse_dir_button, "command", _->browse_dir_callback(file_name_input))

  load_tests_button = Button(frame, "Load tests")
  pack(load_tests_button, fill="both")
  bind(load_tests_button, "command") do _
    load_tests_button_callback(frame, file_name_function)
  end

  run_tests_button = Button(frame, "Run tests")
  pack(run_tests_button, fill="both")
  bind(run_tests_button, "command") do _
    run_tests_button_callback(frame, file_name_function)
  end

  tests_list_frame = Labelframe(frame, "Tests")
  pack(tests_list_frame, fill="both")

  test_details_frame = Labelframe(frame, "Test result details")
  pack(test_details_frame, fill="both")

  frame
end

function browse_dir_callback(file_name_input::Tk_Widget)
  choice = GetOpenFile()
  set_value(file_name_input, choice)
end

function process_tests_callback(frame::Tk_Frame, file_name_func::Function, processing_func::Function, display_tests::Function, clear_tests::Function)
  clear_tests(frame)
  try
    display_tests(frame, () -> processing_func(file_name_func), ()->file_name_func())
  catch
    Messagebox(frame, "Uncorrect file with tests")
  end
end

function clear_current_tests(frame::Tk_Frame, hidden_tests_groups_ids::Vector{Int})
  empty!(hidden_tests_groups_ids)
  clear_all_tests(frame)
  clear_all_test_details(frame)
end

function tests_header_callback(frame::Tk_Frame, testNode::TestStructureNode, tests_structure::Vector{TestStructureNode}, file_name_func::Function, hidden_tests_groups_ids::Vector{Int})
  if testNode.line in hidden_tests_groups_ids
    hidden_tests_groups_ids = filter(x -> x != testNode.line, hidden_tests_groups_ids)
  else
    push!(hidden_tests_groups_ids, testNode.line)
  end
  clear_all_tests(frame)
  display_all_tests(frame, tests_structure, file_name_func, (_frame, node, file_name_func, testStructure)-> display_nodes(_frame, node, testStructure, file_name_func, hidden_tests_groups_ids::Vector{Int}))
end

function single_test_callback(frame::Tk_Frame, testNode::TestStructureNode)
  clear_all_test_details(frame)
  test_details = get(testNode.details, "")
  display_test_details(frame, test_details)
end

function display_test_details(frame::Tk_Frame, test_details::AbstractString)
  if(test_details == "")
    return
  end

  open_details_button = Button(get_frame_for_test_details(frame), "Open details in new window")
  pack(open_details_button)
  bind(open_details_button, "command", _->open_details_button_callback(test_details))

  details_box = get_details_box(frame, test_details)
  pack(details_box)
end

function get_details_box(frame::Tk_Frame, test_details::AbstractString)
  frame_for_details = Frame(get_frame_for_test_details(frame))
  details_box = Text(frame_for_details)
  scrollbars_add(frame_for_details, details_box)
  pack(frame_for_details, expand=true, fill = "both")
  set_value(details_box, test_details)
  details_box[:state] = "disabled"
  details_box
end

function open_details_button_callback(test_details::AbstractString)
  open_new_window(test_details, 400, 350)
end

function open_new_window(text::AbstractString, width::Int, height::Int)
  window = Toplevel("Test Details", width, height)
  pack_stop_propagate(window)

  frame = Frame(window, padding = [3,3,2,2])
  pack(frame, expand = true, fill = "both")

  label  = Label(frame, text)
  grid(label, 1, 1)
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

function draw_node(frame::Tk_Frame, testNode::TestStructureNode, tests_structure::Vector{TestStructureNode}, file_name_func::Function, hidden_tests_groups_ids::Vector{Int})
  frame_for_tests = get_frame_for_tests(frame)
  button_text = testNode.name == "" ? "Tests context" : testNode.name
  if isa(testNode, TestRunner.FactNode)
    test_result = get_result(testNode)
    img = get_image(test_result)
    node_label = Label(frame_for_tests, button_text, img)
    node_label[:background]="white smoke"
    bind(node_label, "<Button-1>") do _
      single_test_callback(frame, testNode)
    end
    line_number_button = Button(node_label,"line: $(testNode.line)")
    pack(line_number_button, anchor="e")
    bind(line_number_button, "<Button-1>") do _
      line_number_button_callback(testNode, file_name_func())
    end
  else
    node_label = Label(frame_for_tests, button_text)
    node_label[:background]="#C0C0C0"
    bind(node_label, "<Button-1>") do _
      tests_header_callback(frame, testNode, tests_structure, file_name_func, hidden_tests_groups_ids)
    end
  end
  pack(node_label, fill="both")
end

line_number_button_callback(testNode::TestStructureNode, tests_file_name::AbstractString) =
  @async run(`$source_path/lineNumberOnClick.sh $(testNode.line) $tests_file_name`)

function display_nodes(frame::Tk_Frame, testNode::TestStructureNode, tests_structure::Vector{TestStructureNode}, file_name_func::Function, hidden_tests_groups_ids::Vector{Int})
  draw_node(frame, testNode, tests_structure, file_name_func, hidden_tests_groups_ids)
  if !(testNode.line in hidden_tests_groups_ids)
    map(child -> display_nodes(frame, child, tests_structure, file_name_func, hidden_tests_groups_ids), TestRunner.children(testNode))
  end
end

function display_all_tests(frame::Tk_Frame, testStructure::Vector{TestStructureNode}, file_name_func::Function, display_test::Function)
  for node in testStructure
    display_test(frame, node, file_name_func, testStructure)
  end
end

get_frame_for_tests(frame::Tk_Frame) = filter(x->isa(x, Tk.Tk_Labelframe), frame.children)[1]

get_frame_for_test_details(frame::Tk_Frame) = filter(x->isa(x, Tk.Tk_Labelframe), frame.children)[2]

function clear_all_children(frame::Union{Tk_Frame, Tk_Labelframe, Tk.Tk_Text})
  map(child->forget(child), frame.children)
  empty!(frame.children)
end

clear_all_tests(frame::Tk_Frame) = clear_all_children(get_frame_for_tests(frame))

clear_all_test_details(frame::Tk_Frame) = clear_all_children(get_frame_for_test_details(frame))

end # module
