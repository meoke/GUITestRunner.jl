using GUITestRunner
using FactCheck

not_throw(_) = true

facts("Helper functions tests") do
  context("get_image") do
	@fact_throws ErrorException GUITestRunner.get_image(:pies) 
  end
end
