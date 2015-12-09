module GUITestRunner
using Tk
using TestRunner

function CreateMainWindow()
  widgets = Array(Tk.Widget, 0)
  testsCheckbuttons = Array(Tk.Widget,0)

  w = Tk.Toplevel("Julia Test Runner", 350, 600)
  pack_stop_propagate(w)

  f = Frame(w, padding = [3,3,2,2])
  pack(f, expand = true, fill = "both")

  l  = Label(f, "Specify file with your tests:")
  grid(l, 1,1)

  fileNameInput = Entry(f)
  grid(fileNameInput, 1, 2)

  load_tests_button = Button(f, "Load tests!")
  formlayout(load_tests_button, nothing)

  #for testing
  set_value(fileNameInput, "/home/student/.julia/v0.4/GUITestRunner/test/sampleTests.jl")
  bind(load_tests_button, "command", (x)->load_tests_callback(x, f, ()->get_value(fileNameInput)))
end

function addFactsNode(testNode::TestStructureNode, frame::Tk.Tk_Frame)
  cb = Checkbutton(frame, testNode.name)
  formlayout(cb, nothing)
  for child in TestRunner.children(testNode)
    addFactsNode(child, frame)
  end
end

function load_tests_callback(not_used, frame::Tk.Tk_Frame, file_name_func::Function)
    file_name = file_name_func()
    testStructure = get_tests_structure(file_name)
    clean_old_test(frame)
    display_tests(testStructure, frame)
end

function display_tests(testStructure::Vector{TestStructureNode}, frame::Tk.Tk_Frame)
  for node in testStructure
    addFactsNode(node, frame)
  end
end

function clean_old_test(frame::Tk.Tk_Frame)
  for child in Tk.children(frame)
    dump(child)
  end
end

end # module
