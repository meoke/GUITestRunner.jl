module GUITestRunner
using Tk
using TestRunner

hidden_tests_groups_names = Array(AbstractString, 0)

function run()
tests_structure = Array(TestStructureNode, 0)
frame = create_main_window(tests_structure)
end

function create_main_window(tests_structure::Array{TestStructureNode})
  window = Tk.Toplevel("Julia Test Runner", 350, 600)
  pack_stop_propagate(window)

  frame = Frame(window, padding = [3,3,2,2])
  pack(frame, expand = true, fill = "both")

  file_name_input = Entry(frame)
  pack(file_name_input)

  browse_dir_button = Button(frame, "...")
  pack(browse_dir_button)
  bind(browse_dir_button, "command", (x)->browse_dir_callback(x, file_name_input))

  load_tests_button = Button(frame, "Load tests!")
  pack(load_tests_button)
  bind(load_tests_button, "command", (x)->load_tests_callback(x, frame, ()->get_value(file_name_input), tests_structure))

  #set values for testing
  set_value(file_name_input, "/home/student/.julia/v0.4/GUITestRunner/test/sampleTests.jl")

  run_tests_button = Button(frame, "Run tests!")
  pack(run_tests_button)
  bind(run_tests_button, "command", (x)->run_tests_callback(x, frame, ()->get_value(file_name_input), tests_structure))

  tests_list_frame = Labelframe(frame, "Tests")
  pack(tests_list_frame)
  scrollbars_add(frame, tests_list_frame.w)
  frame
end

function browse_dir_callback(not_used, file_name_input)
  choice = GetOpenFile()
  set_value(file_name_input, choice)
end

function load_tests_callback(not_used, frame::Tk.Tk_Frame, file_name_func::Function, tests_structure)
    file_name = file_name_func()
    tests_structure = get_tests_structure(file_name)
    frame_for_tests = get_frame_for_tests(frame)
    reset_hidden_tests()
    clear_old_test(frame_for_tests)
    display_all_tests(tests_structure, frame_for_tests)
end

function tests_header_callback(not_used, testNode::TestStructureNode, frame::Tk.Tk_Labelframe, tests_structure::Vector{TestStructureNode})
  global hidden_tests_groups_names
  if testNode.name in hidden_tests_groups_names
    hidden_tests_groups_names = filter(x -> x != testNode.name, hidden_tests_groups_names)
  else
    push!(hidden_tests_groups_names, testNode.name)
  end
  clear_old_test(frame)
  display_all_tests(tests_structure, frame)
end

function run_tests_callback(not_used, frame::Tk.Tk_Frame, file_name_func::Function, tests_structure)
  file_name = file_name_func()
  tests_structure = TestRunner.run_all_tests(file_name)
  frame_for_tests = get_frame_for_tests(frame)
  reset_hidden_tests()
  clear_old_test(frame_for_tests)
  display_all_tests(tests_structure, frame_for_tests)
end

function reset_hidden_tests()
  empty!(hidden_tests_groups_names)
end

function CreateButtonForTest(testNode::Union{FactsCollectionNode, FactNode}, frame::Tk.Tk_Labelframe, tests_structure::Vector{TestStructureNode})
  if :result in fieldnames(testNode)
    img_name = "question.png"
    try
      test_result = get(testNode.result)
      test_result == true ? img_name = "success.png"  : img_name = "failure.png"
    catch
    end
    println(img_name)
    img_path = Pkg.dir("GUITestRunner", "images", img_name)
    img = Image(img_path)
    node_button = Button(frame, text=testNode.name, image=img, compound="left")
  else
    node_button = Button(frame, text=testNode.name, compound="left")
    bind(node_button, "command", (x)->tests_header_callback(x, testNode, frame, tests_structure))
  end
  node_button
end

function draw_node(testNode::TestStructureNode, frame::Tk.Tk_Labelframe, tests_structure::Vector{TestStructureNode})
  node_button = CreateButtonForTest(testNode, frame, tests_structure)
  pack(node_button)
end

function display_facts_node(testNode::TestStructureNode, frame::Tk.Tk_Labelframe, tests_structure::Vector{TestStructureNode})
  draw_node(testNode, frame, tests_structure)
  if testNode.name in hidden_tests_groups_names
    return
  end
  for child in TestRunner.children(testNode)
    display_facts_node(child, frame, tests_structure)
  end
end

function display_all_tests(testStructure::Vector{TestStructureNode}, frame::Tk.Tk_Labelframe)
  for node in testStructure
    display_facts_node(node, frame, testStructure)
  end
end

function clear_old_test(frame::Tk.Tk_Labelframe)
  tests_to_remove = frame.children
  for test in tests_to_remove
    forget(test)
  end
  empty!(tests_to_remove)
end

function get_frame_for_tests(frame::Tk.Tk_Frame)
  filter(x->isa(x, Tk.Tk_Labelframe), frame.children)[1]
end

end # module
