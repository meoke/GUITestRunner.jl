using Tk
using TestRunner

import TestRunner: TestStructureNode, FactsCollectionNode, FactNode, children, ContextNode
import Tk:Tk_Frame, Tk_Labelframe, Tk_Label

test_result_images = Dict(test_success => "success.png", test_failure => "failure.png", test_error => "error.png", test_pending => "pending.png", test_not_run => "not_run.png")

function create_main_window()
  window = Toplevel("Julia Test Runner", 350, 600)
  pack_stop_propagate(window)
  bind(window, "<Control-r>", _ -> run_tests_button_callback!(frame))
  bind(window, "<Control-l>", _ -> load_tests_button_callback!(frame))

  frame = Frame(window, padding = [3,3,2,2])
  pack(frame, expand = true, fill = "both")

  file_name_input = Entry(frame)
  global get_file_name
  get_file_name = () -> get_value(file_name_input)

  pack(file_name_input, fill="both")

  #set values for testing
  #set_value(file_name_input, "/home/student/.julia/v0.4/GUITestRunner/test/sampleTests.jl")

  browse_dir_button = Button(frame, "Choose file")
  pack(browse_dir_button, fill="both")
  bind(browse_dir_button, "command", _->browse_dir_callback!(file_name_input))

  load_tests_button = Button(frame, "Load tests")
  pack(load_tests_button, fill="both")
  bind(load_tests_button, "command", _ -> load_tests_button_callback!(frame))

  run_tests_button = Button(frame, "Run tests")
  pack(run_tests_button, fill="both")
  bind(run_tests_button, "command",  _ -> run_tests_button_callback!(frame))

  tests_list_frame = Labelframe(frame, "Tests")
  pack(tests_list_frame, fill="both")

  test_details_frame = Labelframe(frame, "Test result details")
  pack(test_details_frame, fill="both")

  window
end

function create_new_window(text::AbstractString, width::Int, height::Int)
  window = Toplevel("Test details", width, height)
  pack_stop_propagate(window)

  frame = Frame(window, padding = [3,3,2,2])
  pack(frame, expand = true, fill = "both")

  label  = Label(frame, text)
  pack(label, side="left", anchor ="nw")
  window
end

function create_open_details_button!(frame::Tk.Tk_Frame, test_details::AbstractString)
  open_details_button = Button(get_frame_for_test_details(frame), "Open details in new window")
  pack(open_details_button)
  bind(open_details_button, "command", _ -> open_details_button_callback(test_details))
end

function create_details_textbox!(frame::Tk_Frame, test_details::AbstractString)
  frame_for_details = Frame(get_frame_for_test_details(frame))
  details_box = Text(frame_for_details)
  scrollbars_add(frame_for_details, details_box)
  pack(frame_for_details, expand=true, fill = "both")
  set_value(details_box, test_details)
  details_box[:state] = "disabled"
  pack(details_box)
end

function get_node_label!(frame::Tk_Frame,tests_structure::Vector{TestStructureNode}, test_node::FactNode,nesting_level::Int)
  frame_for_tests = get_frame_for_tests(frame)
  button_text = name(test_node)
  img = test_node |> result |> get_image
  node_label = Label(frame_for_tests, button_text, img)
  node_label[:background]=get_color(test_node)
  bind(node_label, "<Button-1>", _ -> single_test_callback!(frame, test_node))

  create_line_number_button!(node_label, test_node)
  nesting_level, node_label
end

function create_line_number_button!(node_label::Tk_Label, test_node::FactNode)
  line_number_button = Button(node_label,"line: $(line(test_node))")
  pack(line_number_button, anchor="e")
  bind(line_number_button, "<Button-1>", _ -> line_number_button_callback(test_node, get_file_name()))
end

function get_node_label!(frame::Tk_Frame,tests_structure::Vector{TestStructureNode},test_node::TestStructureNode, nesting_level::Int)
  frame_for_tests = get_frame_for_tests(frame)
  button_text = name(test_node)
  node_label = Label(frame_for_tests, button_text)
  node_label[:background]=get_color(test_node)
  bind(node_label, "<Button-1>", _ -> tests_header_callback!(frame, test_node, tests_structure))

  nesting_level+=1
  nesting_level, node_label
end

function get_image(result::RESULT)
  img_name = get(test_result_images, result, "not_run.png")
  img_path = Pkg.dir("GUITestRunner", "images", img_name)
  Image(img_path)
end

get_color(element::FactsCollectionNode) = "#C0C0C0"

get_color(element::ContextNode) = "#FFCC99"

get_color(element::FactNode) = "white smoke"
