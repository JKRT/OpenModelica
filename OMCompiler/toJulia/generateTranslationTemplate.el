;; To generate files to translate using Emacs

;;TODO add more files here...
(setq util-files '(Array Autoconf  AvlSetCR AvlSetInt AvlSetPath AvlSetString AvlTreeCRToInt AvlTree AvlTreeString AvlTreeStringString BaseAvlSet BaseAvlTree BaseHashSet BaseHashTable BasePVector BaseVector ClockIndexes Config Corba Database Debug DiffAlgorithm DisjointSets DoubleEnded DynLoad ErrorExt Error ExecStat ExpandableArray File Flags FMIExt FMI GC GraphML Graph GraphStreamExt GraphStream HashSetExp HashSet HashSetString HashTable2 HashTable3 HashTable4 HashTable5 HashTable6 HashTableCG HashTableCrefSimVar HashTableCrIListArray HashTableCrILst HashTableCrIntToExp HashTableCrToCrEqLst HashTableCrToExp HashTableCrToExpOption HashTableCrToExpSourceTpl HashTableCrToUnit HashTableExpToExp HashTableExpToIndexExp HashTableExpToIndex HashTable HashTablePathToFunction HashTableSimCodeEqCache HashTableSM1 HashTableStringToPath HashTableStringToProgram HashTableStringToUnit HashTableTypeToExpType HashTableUnitToString IOStreamExt IOStream JSONExt Lapack List MessagePack ModelicaExternalC Mutable Pointer Print PriorityQueue Serializer Settings SimulationResults Socket StackOverflow StringUtil System TaskGraphResults Util VarTransform ZeroMQ))

;;TODO add frontend files and NFFrontend files and so on...

(setq old-frontend '(
                     Absyn AbsynToSCode AbsynUtil Algorithm AvlTreePathFunction BackendInterface Builtin CevalFunction Ceval Checdel ClassInf ClassLoader ComponentReference ConnectionGraph Connect ConnectUtil Constants DAEDump DAE DAEUtil DumpGraphviz Dump ElementSource ExpressionDump Expression ExpressionSimplify ExpressionSimplifyTypes Graphviz Inline InnerOuter InstBinding InstDAE InstExtends InstFunction InstHashTable InstMeta Inst InstSection InstStateMachineUtil InstTypes InstUtil InstVar Lookup MetdelicaBuiltin MetaUtil MMathdelicaBuiltind NFEnvExtends NFInstDump NFInstPrefix NFInstTypes NFInstUtil NFSCodeCheck NFSCodeDependency NFSCodeEnv NFSCodeFlattenImports NFSCodeFlatten NFSCodeFlattenRedeclare NFSCodeLookup OperatorOverloading ParserExt Parser Patternm PDdelicaBuiltin Prefix PrefixUtil SCodeDump SCodeInstUtil SCode SCodeSimplify SCodeUtil StateMachineFlatten Static Types UnitAbsynBuilder UnitAbsyn UnitChecker UnitParserExt Values ValuesUtil))

(setq ffrontend '(FBuiltin FCore FExpand FGraphBuildEnv FGraphBuild FGraphDump FGraph FGraphStream FInst FLookup FMod FNode FResolve FTraverse FVisit))


(defun genLoadFileTPL (name)
  (insert
   (format
    "
      print(\"Translating %s into Julia!\\n\"); getErrorString();
      loadFile(\"Compiler/Util/%s\"); getErrorString();
      writeFile(\"toJulia/toJuliaOutput/Util/%s.jl\",
      OpenModelica.Scripting.Experimental.toJulia()); getErrorString();
      deleteClass(%s); getErrorString();
   " name name name name )))

(defun genLoadFileTPLOF (name)
  (insert
   (format
    "
      print(\"Translating %s into Julia!\\n\"); getErrorString();
      loadFile(\"Compiler/FrontEnd/%s.mo\"); getErrorString();
      writeFile(\"toJulia/toJuliaOutput/FrontEnd/%s.jl\",
      OpenModelica.Scripting.Experimental.toJulia()); getErrorString();
      deleteClass(%s); getErrorString();
   " name name name name )))

(defun genLoadFileTPLFF (name)
  (insert
   (format
    "
      print(\"Translating %s into Julia!\\n\"); getErrorString();
      loadFile(\"Compiler/FFrontEnd/%s.mo\"); getErrorString();
      writeFile(\"toJulia/toJuliaOutput/FFrontEnd/%s.jl\",
      OpenModelica.Scripting.Experimental.toJulia()); getErrorString();
      deleteClass(%s); getErrorString();
   " name name name name )))


(defun generate-util-files ()
    (interactive)
    (insert
     "
     /*
     *     Automatically generated by generateTranslationTemplate.el
     *     @author Emacs
     */
     setCommandLineOptions(\"-g=MetaModelica\");getErrorString();
     ")
    (mapcar 'genLoadFileTPL util-files))


(defun generate-ffrontend-files ()
    (interactive)
    (insert
     "
     /*
     *     Automatically generated by generateTranslationTemplate.el
     *     @author Emacs
     */
     setCommandLineOptions(\"-g=MetaModelica\");getErrorString();
     ")
    (mapcar 'genLoadFileTPLFF ffrontend))


(defun generate-oldfrontend-files ()
    (interactive)
    (insert
     "
     /*
     *     Automatically generated by generateTranslationTemplate.el
     *     @author Emacs
     */
     setCommandLineOptions(\"-g=MetaModelica\");getErrorString();
     ")
    (mapcar 'genLoadFileTPLOF old-frontend))
