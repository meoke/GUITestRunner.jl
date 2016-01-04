using FactCheck

facts("First facts group") do
  @fact 1 --> 1 "Success"
  @fact 1 --> 2 "Failure"
  @fact 2 --> 2 #Nameless fact
  @fact error("test") --> 1 "Error"
  @pending 1-->isempty([]) "Pending"
  context("My context") do
    @fact 1 --> 1 "My context Test 1 - success"
    @fact 1 --> 2 "My context Test 2 - failure"
  end
  @fact 2 --> 2 "Success"
end

facts("Second facts group") do
  @fact error("test2") --> 1 "Error"
  @fact 1--> 2 "Failure"
  facts("Nesting level 1") do
    @fact 1--> 1 "Success"
    @fact 1--> 2 "Failure"
    facts("Nesting level 2") do
      @fact 1--> 1 "Failure"
      @pending 1--> 2 "Pending"
    end
  end
  context("My 2nd context") do
    @fact 1 --> 1 "My 2nd context Test 1 - success"
    @fact 1 --> 2 "My 2nd context Test 2 - failure"
  end
end
