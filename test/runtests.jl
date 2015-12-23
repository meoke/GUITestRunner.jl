using GUITestRunner
using FactCheck

not_throw(_) = true

facts("Helper functions tests") do
  context("geting test buttons icons") do
	@windows? (
         begin
            @pending GUITestRunner.get_image(:success) --> not_throw
            @pending GUITestRunner.get_image(:question)--> not_throw
			@pending GUITestRunner.get_image(:failure) --> not_throw
         end
       : begin
			@fact GUITestRunner.get_image(:success) --> not_throw
            @fact GUITestRunner.get_image(:question)--> not_throw
			@fact GUITestRunner.get_image(:failure) --> not_throw
         end
       )
	@fact_throws ErrorException GUITestRunner.get_image(:pies) 
  end
end
