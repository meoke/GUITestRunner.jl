module GUITestRunner
using Tk
using TestRunner

hidden_tests_groups_names = AbstractString[]

function run()
  tests_structure = TestStructureNode[]
  frame = create_main_window(tests_structure)
end

function create_main_window(tests_structure::Vector{TestStructureNode})
  window = Toplevel("Julia Test Runner", 350, 600)
  pack_stop_propagate(window)

  frame = Frame(window, padding = [3,3,2,2])
  pack(frame, expand = true, fill = "both")

  file_name_input = Entry(frame)
  pack(file_name_input)
  #grid(file_name_input, 1, 1)

  browse_dir_button = Button(frame, "...")
  pack(browse_dir_button)
  #grid(browse_dir_button, 1, 3)
  bind(browse_dir_button, "command", x->browse_dir_callback(file_name_input))

  load_tests_button = Button(frame, "Load tests!")
  pack(load_tests_button)
  bind(load_tests_button, "command") do _
    load_tests_callback(frame, ()->get_value(file_name_input), tests_structure)
  end

  #set values for testing
  set_value(file_name_input, "/home/student/.julia/v0.4/GUITestRunner/test/sampleTests.jl")

  run_tests_button = Button(frame, "Run tests!")
  pack(run_tests_button)
  bind(run_tests_button, "command") do _
      run_tests_callback(frame, () -> get_value(file_name_input), tests_structure)
  end

  tests_list_frame = Labelframe(frame, "Tests")
  pack(tests_list_frame)

  test_details_frame = Labelframe(frame, "Test result details")
  pack(test_details_frame)

  frame
end

function browse_dir_callback(file_name_input)
  choice = GetOpenFile()
  set_value(file_name_input, choice)
end

function load_tests_callback(frame::Tk.Tk_Frame, file_name_func::Function, tests_structure)
    file_with_tests_name = file_name_func()
    tests_structure = get_tests_structure(file_with_tests_name)
    reset_hidden_tests()
    clear_all_children(get_frame_for_tests(frame))
    clear_all_children(get_frame_for_test_details(frame))
    display_all_tests(tests_structure, frame)
    println(file_with_tests_name)
end

function tests_header_callback(testNode::TestStructureNode, frame::Tk.Tk_Frame, tests_structure::Vector{TestStructureNode})
  global hidden_tests_groups_names
  if testNode.name in hidden_tests_groups_names
    hidden_tests_groups_names = filter(x -> x != testNode.name, hidden_tests_groups_names)
  else
    push!(hidden_tests_groups_names, testNode.name)
  end
  clear_all_children(get_frame_for_tests(frame))
  display_all_tests(tests_structure, frame)# tu brakuje labela dla detailsów
end

function single_test_callback(testNode::TestStructureNode, frame::Tk.Tk_Frame)
  tests_details_frame = get_frame_for_test_details(frame)
  clear_all_children(tests_details_frame)
  test_details = ""
  try
    test_details = get(testNode.details)
  catch
    return
  end
  l  = Label(tests_details_frame, test_details)
  pack(l)
end

function run_tests_callback(frame::Tk.Tk_Frame, file_name_func::Function, tests_structure)
  file_with_tests_name = file_name_func()
  tests_structure = TestRunner.run_all_tests(file_with_tests_name)
  clear_all_children(get_frame_for_tests(frame))
  display_all_tests(tests_structure, frame)
end

reset_hidden_tests() = empty!(hidden_tests_groups_names)

function CreateButtonForTest(testNode::Union{FactsCollectionNode, FactNode}, frame::Tk.Tk_Frame, tests_structure::Vector{TestStructureNode})
  frame_for_tests = get_frame_for_tests(frame)
  if :result in fieldnames(testNode)
    img_name = "question.png"
    try
      test_result = get(testNode.result)
      test_result == true ? img_name = "success.png" : img_name = "failure.png"
    catch
    end
    img_path = Pkg.dir("GUITestRunner", "images", img_name)
    img = Image(img_path)
    node_button = Button(frame_for_tests, text=testNode.name, image=img, compound="left")
    bind(node_button, "command", x->single_test_callback(testNode, frame))
  else
    node_button = Button(frame_for_tests, text=testNode.name, compound="left")
    bind(node_button, "command", x->tests_header_callback(testNode, frame, tests_structure))
  end
  node_button
end

function draw_node(testNode::TestStructureNode, frame::Tk.Tk_Frame, tests_structure::Vector{TestStructureNode})
  node_button = CreateButtonForTest(testNode, frame, tests_structure)
  pack(node_button)
end

function display_facts_node(testNode::TestStructureNode, frame::Tk.Tk_Frame, tests_structure::Vector{TestStructureNode})
  draw_node(testNode, frame, tests_structure)
  if !(testNode.name in hidden_tests_groups_names)
    map(child -> display_facts_node(child, frame, tests_structure), TestRunner.children(testNode))
  end
end

display_all_tests(testStructure::Vector{TestStructureNode}, frame::Tk.Tk_Frame) = map(node->display_facts_node(node, frame, testStructure), testStructure)

get_frame_for_tests(frame::Tk.Tk_Frame) = filter(x->isa(x, Tk.Tk_Labelframe), frame.children)[1]

get_frame_for_test_details(frame::Tk.Tk_Frame) = filter(x->isa(x, Tk.Tk_Labelframe), frame.children)[2]

function clear_all_children(frame::Union{Tk.Tk_Frame, Tk.Tk_Labelframe})
  map(child->forget(child), frame.children)
  empty!(frame.children)
end

end # module
