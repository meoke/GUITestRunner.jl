using GUITestRunner
using FactCheck

not_throw(_) = true

facts("Helper functions tests") do
  context("get_image") do
	@fact_throws ErrorException GUITestRunner.get_image(:pies) 
	@windows? (
         begin
             @pending GUITestRunner.get_image(:question) --> not_throw
         end
       : begin
             @fact GUITestRunner.get_image(:question) --> not_throw
         end
       )
  end
end
