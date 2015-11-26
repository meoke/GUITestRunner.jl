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

  readFileBtn = Button(f, "Load tests!")
  formlayout(readFileBtn, nothing)

  for i in 1:10
    cb = Checkbutton(f, "Test$i")
    formlayout(cb, nothing)
  end

  bind(readFileBtn, "command", load_tests)
end

function printFactsNode(testNode)
  println(testNode.name)
  for i in 1:length(testNode.childs)
    if(isa(testNode.childs[i], FactNode))
      println(testNode.childs[i].name)
    else
      for j in 1:length(testNode.childs[i].childs)
        printFactsNode(testNode.childs[i].childs[j])
      end
    end
  end
end

function load_tests(path)
    #val = get_value(fileNameInput)
    val = "/home/student/.julia/v0.4/GUITestRunner/test/sampleTests.jl"
    testStructure::Vector{TestStructureNode} = TestRunner.get_tests_structure(val)
    for i in 1:length(testStructure)
      printFactsNode(testStructure[i])
    end
end

end # module
