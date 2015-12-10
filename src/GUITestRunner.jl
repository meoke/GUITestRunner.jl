module GUITestRunner
using Tk
using TestRunner

hidden_tests_groups_names = Array(AbstractString, 0)
tests_structure = Array(TestStructureNode, 0)
tests_nodes = Array(Tk.Tk_Widget,0)

function CreateMainWindow()
  widgets = Array(Tk.Widget, 0)
  testsCheckbuttons = Array(Tk.Widget,0)

  w = Tk.Toplevel("Julia Test Runner", 350, 600)
  pack_stop_propagate(w)

  f = Frame(w, padding = [3,3,2,2])
  pack(f, expand = true, fill = "both")


  fileNameInput = Entry(f)

  grid(fileNameInput, 1, 1)

  browse_dir_button = Button(f, "...")
  grid(browse_dir_button, 1, 2)
  bind(browse_dir_button, "command", (x)->browse_dir_callback(x, ()->fileNameInput))

  load_tests_button = Button(f, "Load tests!")
  grid(load_tests_button, 3, 2)

  bind(load_tests_button, "command", (x)->load_tests_callback(x, f, ()->get_value(fileNameInput), ()->Tk.children(f)))
end

function browse_dir_callback(not_used, get_input_func)
  choice = GetOpenFile()
  file_name_input = get_input_func()
  set_value(file_name_input, choice)
end

function draw_node(testNode::TestStructureNode, frame::Tk.Tk_Frame)
  if :result in fieldnames(testNode)
    if testNode.result == true
      img_name = "success.png"
    elseif testNode.result == false
      img_name = "failure.png"
    else
      img_name = "question.png"
    end
    img_path = Pkg.dir("GUITestRunner", "images", img_name)
    img = Image(img_path)
    node_button = Button(frame, text=testNode.name, image=img, compound="left")
  else
    node_button = Button(frame, text=testNode.name, compound="left")
    bind(node_button, "command", (x)->tests_header_callback(x, ()->Tk.children(frame), testNode, frame))
  end
  #push!(tests_nodes, node_button)
  Tk.get_path(node_button)
  formlayout(node_button, nothing)
end

function add_facts_node(testNode::TestStructureNode, frame::Tk.Tk_Frame)
  draw_node(testNode, frame)
  if testNode.name in hidden_tests_groups_names
    return
  end
  for child in TestRunner.children(testNode)
    add_facts_node(child, frame)
  end
end

function load_tests_callback(not_used, frame::Tk.Tk_Frame, file_name_func::Function, frame_children_func::Function)
    file_name = file_name_func()
    global tests_structure = get_tests_structure(file_name)
    children = frame_children_func()
    clean_old_test(children, frame)
    display_tests(tests_structure, frame)
end

function tests_header_callback(not_used, frame_children_func::Function, testNode::TestStructureNode, frame::Tk.Tk_Frame)
  global hidden_tests_groups_names
  if testNode.name in hidden_tests_groups_names
    hidden_tests_groups_names = filter(x -> x != testNode.name, hidden_tests_groups_names)
  else
    push!(hidden_tests_groups_names, testNode.name)
  end
  children = frame_children_func()
  clean_old_test(children, frame)
  display_tests(tests_structure, frame)
end

function display_tests(testStructure::Vector{TestStructureNode}, frame::Tk.Tk_Frame)
  for node in testStructure
    add_facts_node(node, frame)
  end
end

function clean_old_test(children,frame::Tk.Tk_Frame)
  global tests_nodes
  for child in children
    if isa(child, Tk.Tk_Button) && child in tests_nodes
      idx = findfirst(tests_nodes, child)
      deleteat!(tests_nodes, idx)
      Tk.forget(frame, child)
    end
  end
end

end # module
