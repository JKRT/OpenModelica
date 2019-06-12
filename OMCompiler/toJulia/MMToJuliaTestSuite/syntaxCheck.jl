module SyntaxTest
#=
#    This part of the tests checks that the files generated by MMTojulia.dumpProgram complies
#    to the syntactic rules of Julia. No semantic check
=#
using Test
include("../metaModelicaToJulia.jl")

function syntaxCheck(omc)
  @assert pwd() == abspath(".")[1:end - 1] "Tests should be run from the suite"
  global PRIMITIVES_DIRECTORY = abspath("./Primitives")
  checkHome = pwd()
  outPrimitivesDirectory = createDirectoryReportErrorOnFailure(abspath("./OutputPrimitives"))
  translateFilesIfOutputIsEmpty(outPrimitivesDirectory, omc)
  checkSyntax(outPrimitivesDirectory, "Primitives")
  cd(checkHome)
  # outAlgsDirectory = createDirectoryReportErrorOnFailure(abspath("./OutputAlgorithms"))
  # translateFilesIfOutputIsEmpty(outAlgsDirectory, omc)
  # checkSyntax(outAlgsDirectory, "Algorithms")
  # cd(checkHome)
  #More tests below..
end

function createDirectoryReportErrorOnFailure(dirToCreate)
  directory = dirToCreate
  if !isdir(directory)
    mkdir(directory)
  end
  @assert isdir(directory) "Failed to create directory. Aborting test"
  return directory
end

function translateFilesIfOutputIsEmpty(directory, omc)
  cd(PRIMITIVES_DIRECTORY)
  if size(readdir(directory),1) < 3
    filesToConvert = [abspath(f) for f in filter(x -> endswith(x, "mo"), readdir())]
    metaModelicaToJulia(filesToConvert, omc, directory)
  end
  cd("..")
end

function checkSyntax(directory, description)
  # @testset "Syntax for $description: " begin
  #   cd(abspath("$directory"))
  #   for f in filter(x -> endswith(x, "jl"), readdir())
  #     println("Parsing: $f...")
  #     fileContents = read(f, String)
  #     try
  #       @test_nowarn eval(Meta.parse(fileContents))
  #     catch
  #       @test false
  #     end
  #   end
  # end
end
end #= End syntaxCheck.jl=#
