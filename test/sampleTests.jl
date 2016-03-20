using FactCheck

facts("Math module tests") do
  @fact 1 --> 1 "Primary numbers less than 100 search"
  @pending 1-->isempty([]) ""
  context("Trigonometric functions") do
    @fact 1 --> 1 "Sine"
    @fact 1 --> 2 "Cosine"
	@fact 1 --> 1 "Tangent"
  end
  @fact 2 --> 2 "Units of measurment"
end

facts("Words processing tests") do
  @fact error("test2") --> 1 "Make palindrome"
  @fact 1--> 2 "Make anagrame"
  context("Translate") do
	facts("From English") do
		@fact 1--> 1 "From English to Spanish"
		@fact 1--> 2 "From English to German"
	end
    facts("To English") do
      @fact 1--> 1 "From Spanish to English"
      @pending 1--> 2 "From German to English"
    end
  end
end
