


using FactCheck

facts("First facts group") do
  @fact 1 --> 1 "First group first test"
  @fact 1 --> 2 "First group second failing test"
end

facts("Second facts group") do
  @fact 1 --> 1 "Second group first test"
  @fact 1 --> 1 "Second group second test"
  @fact error("test") --> 1 "Error"
  @fact 1-->2 "a"
  #@fact 2 --> 2 #Nameless fact
end

# facts() do #Nameless group
#   @fact 1 --> 1 #Nameless fact
#   @fact 2 --> 1 #Failing nameless fact in nameless group
# end
