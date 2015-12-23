using GUITestRunner
using FactCheck

not_throw(_) = true

facts("Helper functions tests") do
  context("get_image") do
    @pending GUITestRunner.get_image(:question) --> not_throw
  end
end
