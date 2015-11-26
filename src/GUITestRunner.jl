module GUITestRunner
using Tk
using TestRunner

# type TestRunnerWindow
#   mainWindow
#   mainFrame
#   factsWidgets
#   widgets::Array{Tk.Widget}
# end
#
# function CreateWindow()
#   w::TestRunnerWindow
#   w.mainWindow = TK.Toplevel("Julia Test Runner", 350, 600)
#   pack_stop_propagate(w)
#
#   w.mainFrame = Frame(w.mainWindow, padding = [3,3,2,2])
#   pack(w.mainFrame, expand = true, fill = "both")
#
#   l = Label(w.mainFrame, "Specify file with your tests:")
#   grid(l, 1,1)
# end

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

  readFileBtn = Button(f, "Load tests!")
  formlayout(readFileBtn, nothing)

  # for i in 1:10
  #   cb = Checkbutton(f, "Test$i")
  #   formlayout(cb, nothing)
  # end
  print(typeof(f))
  bind(readFileBtn, "command", (x)->load_tests(x, f, widgets))
end

function printFactsNode_console(testNode)
  println(testNode.name)
  for i in 1:length(testNode.childs)
    if(isa(testNode.childs[i], FactNode))
      println(testNode.childs[i].name)
    else
      for j in 1:length(testNode.childs[i].childs)
        printFactsNode_console(testNode.childs[i].childs[j])
      end
    end
  end
end

function addFactsNode(testNode, frame, widgets)
  cb = Checkbutton(frame, testNode.name)
  formlayout(cb, nothing)
  for i in 1:length(testNode.childs)
    if(isa(testNode.childs[i], FactNode))
      cb = Checkbutton(frame, testNode.childs[i].name)
      formlayout(cb, nothing)
    else
      for j in 1:length(testNode.childs[i].childs)
        addFactsNode(testNode.childs[i].childs[j], f, widgets)
      end
    end
  end
end

function load_tests(path,f, widgets)
    #val = get_value(fileNameInput)
    val = "/home/student/.julia/v0.4/GUITestRunner/test/sampleTests.jl"
    testStructure::Vector{TestStructureNode} = TestRunner.get_tests_structure(val)
    for i in 1:length(testStructure)
      printFactsNode_console(testStructure[i])
      addFactsNode(testStructure[i], f, widgets)
    end
end

end # module
