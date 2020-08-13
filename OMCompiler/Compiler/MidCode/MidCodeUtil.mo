/*
 * This file is part of OpenModelica.
 *
 * Copyright (c) 1998-2019, Open Source Modelica Consortium (OSMC),
 * c/o Linköpings universitet, Department of Computer and Information Science,
 * SE-58183 Linköping, Sweden.
 *
 * All rights reserved.
 *
 * THIS PROGRAM IS PROVIDED UNDER THE TERMS OF GPL VERSION 3 LICENSE OR
 * THIS OSMC PUBLIC LICENSE (OSMC-PL) VERSION 1.2.
 * ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS PROGRAM CONSTITUTES
 * RECIPIENT'S ACCEPTANCE OF THE OSMC PUBLIC LICENSE OR THE GPL VERSION 3,
 * ACCORDING TO RECIPIENTS CHOICE.
 *
 * The OpenModelica software and the Open Source Modelica
 * Consortium (OSMC) Public License (OSMC-PL) are obtained
 * from OSMC, either from the above address,
 * from the URLs: http://www.ida.liu.se/pr OpenModelica distribution.
 * GNU version 3 is obtained from: http://www.gnu.org/copyleft/gpl.html.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without
 * even the implied warranty of  MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE, EXCEPT AS EXPRESSLY SET FORTH
 * IN THE BY RECIPIENT SELECTED SUBSIDIARY LICENSE CONDITIONS OF OSMC-PL.
 *
 * See the full OSMC Public License conditions for more details.
 *
*/

encapsulated package MidCodeUtil
" File:        MidCodeUtil
  Package:     MidCodeUtil
  Description: This package contains helper functions related to the MidCode representation.
               All functions defined in this package are public.
  Author: John Tinnerholm
"
protected
import Absyn;
import CodegenUtil;
import DAE;
import DAEDump;
import List;
import MidCode;
import MidCodeDump;
import SimCode.{RecordDeclaration};
import Tpl;
public
function getCalledFunctionsInFunction
  input Absyn.Path functionName;
  input MidCode.Function func;
  output list<Absyn.Path> calledNonBuiltinFunctions;
algorithm
  calledNonBuiltinFunctions := getMidCodeCallTerminators(func);
end getCalledFunctionsInFunction;

function getFunctionStmts
  "Returns all statments for a MidCode function"
  input MidCode.Function f;
  output list<MidCode.Stmt> stmts;
algorithm
  stmts := match f
    case MidCode.FUNCTION(__) then List.mapFlat(f.body,getBodyStmts);
    else fail();
  end match;
end getFunctionStmts;

function getBodyStmts
  input MidCode.Block bl;
  output list<MidCode.Stmt> stmts;
algorithm
  stmts := match bl
    case MidCode.BLOCK(__) then bl.stmts;
    else fail();
  end match;
end getBodyStmts;

function getBBs
  "Retrieves all basic blocks for a MidCode.Function"
  input MidCode.Function f;
  output list<MidCode.Block> bBs;
algorithm
  bBs := match f case MidCode.FUNCTION(__) then f.body; end match;
end getBBs;

function getTerminators
  "Returns the set of terminators for a set of basic blocks"
  input list<MidCode.Block> blcks;
  output list<MidCode.Terminator> terms;
algorithm
  terms := List.map(blcks,getTerminator);
end getTerminators;

function getTerminator
  "Fetches a terminator for a given BB in MidCode."
  input MidCode.Block BB;
  output MidCode.Terminator term;
algorithm
  term := match BB case MidCode.BLOCK(__) then BB.terminator; end match;
end getTerminator;

function getCallTerminator
  input MidCode.Terminator inTerm;
  output MidCode.Terminator outTerm;
algorithm
  outTerm := match inTerm
	case MidCode.CALL(__) then inTerm;
  end match;
end getCallTerminator;

function isNotBuiltinCall
  input MidCode.Terminator call;
  output Boolean b;
algorithm
  b := match call
    case MidCode.CALL(__) then not call.builtin;
    else false;
  end match;
end isNotBuiltinCall;

function isCallTerminator
  input MidCode.Terminator terminator;
  output Boolean isCall;
algorithm
  isCall := match terminator
    case MidCode.CALL(__) then true;
    else false;
  end match;
end isCallTerminator;

function getMidCodeCallTerminators
  "Return the Absyn.path for all call terminators in a given MidCode function."
  input MidCode.Function midFunc;
  input Boolean fetchBuiltinAsWell = false;
  output list<Absyn.Path> functionPaths;
protected
  list<MidCode.Terminator> calls;
algorithm
  calls := getTerminators(getBBs(midFunc));
  calls := List.filterOnTrue(calls,isCallTerminator);
  if not fetchBuiltinAsWell then
	calls := List.filterOnTrue(calls,isNotBuiltinCall);
  end if;
  functionPaths := List.map(calls,getCallTermPath);
end getMidCodeCallTerminators;

function getCallTermPath
  input MidCode.Terminator term;
  output Absyn.Path path;
algorithm
  path := match term
    case MidCode.CALL(__) then term.func;
  end match;
end getCallTermPath;

//TODO:
function getUnionTypePaths
  "Fetches all unionType paths for a list of MidCode functions."
  input list<MidCode.Function> midFuncs;
  output list<Absyn.Path> outPaths;
protected
  list<MidCode.LITERALMETATYPE> metaLits;
algorithm
  /*Fetch all metaLits from the midFuncs*/
//  _ := List.filter(List.mapFlat(midFuncs,getFunctionStmts),isLiteralMetatype);
  outPaths := {};
end getUnionTypePaths;

function blockWithId
  input MidCode.Block bb;
  input Integer id;
  output Boolean b;
algorithm
  b := bb.id == id;
end blockWithId;

/*TODO: Can this be done in a better way?*/
function rValueToLiteralInteger
  input MidCode.RValue rval;
  output Integer r;
  algorithm
  r := match rval
	case MidCode.LITERALINTEGER(__) then rval.value;
    else then fail();
  end match;
end rValueToLiteralInteger;

function rValueToLiteralReal
  input MidCode.RValue rval;
  output Real r;
algorithm
  r := match rval
	case MidCode.LITERALREAL(__) then rval.value;
    else then fail();
  end match;
end rValueToLiteralReal;

function rValueToLiteralBoolean
  input MidCode.RValue rval;
  output Boolean r;
algorithm
  r := match rval
	case MidCode.LITERALBOOLEAN(__) then rval.value;
    else then fail();
  end match;
end rValueToLiteralBoolean;

function rValueToLiteralString
  input MidCode.RValue rval;
  output String r;
algorithm
  r := match rval
	case MidCode.LITERALSTRING(__) then rval.value;
    else then fail();
  end match;
end rValueToLiteralString;

function dumpMidCodeIR
  input MidCode.Function func;
algorithm
  print("inputs:" + anyString(func.inputs) + "\n");
  print("outputs:" + anyString(func.outputs) + "\n");
  print("Locals:" + anyString(func.locals) + "\n");
  for bb in func.body loop
	print("\n"+anyString(bb) + "\n");
  end for;
end dumpMidCodeIR;

function getVarTy
  input MidCode.Var var;
  output DAE.Type ty;
algorithm
  ty := match var case MidCode.VAR(__) then var.ty; end match;
end getVarTy;

function getDimensions
  "I asume that  I get arrays like,
  T_ARRAY(T_ARRAY(T_ARRAY(non_array_type, {dim1}), {dim2}), {dim3}) (Not always true I guess?)"
  input DAE.Type arrayTy;
  output list<DAE.Dimension> dims;
algorithm
  dims := match arrayTy
    case DAE.T_ARRAY(__) then listHead(arrayTy.dims) :: getDimensions(arrayTy.ty);
    case _ then {};
  end match;
end getDimensions;

function getAllocStmts
  input MidCode.Function f;
  output list<MidCode.Stmt> allocaStmts;
algorithm
  allocaStmts := List.filter(getFunctionStmts(f),isAllocStmt);
end getAllocStmts;

function isAllocStmt
  input MidCode.Stmt stmt;
algorithm
  () := match stmt
    case MidCode.ALLOC_ARRAY(__) then ();
    else fail();
  end match;
end isAllocStmt;

function variableName
  input SimCodeFunction.Variable v;
  output String s;
algorithm
  s := match v
    case SimCodeFunction.VARIABLE(name=DAE.CREF_IDENT(ident=s)) then s;
    case SimCodeFunction.FUNCTION_PTR(name=s) then s;
  end match;
end variableName;

function compareSimVars
  input SimCodeFunction.Variable v1;
  input SimCodeFunction.Variable v2;
  output Boolean b;
algorithm
  b := stringEqual(variableName(v1),variableName(v2));
end compareSimVars;

function varToOutVar
  "Converts a var to a outVar"
  input MidCode.Var var;
  output MidCode.OutVar ovar;
algorithm
 ovar := MidCode.OUT_VAR(var);
end varToOutVar;

function listZip<X,Y>
  "List.threadTuple fails for lists of unequal length
   but truncating is the more common semantics."
  input  list<X>          xs;
  input  list<Y>          ys;
  output list<tuple<X,Y>> zs;
protected
  list<X> xs_;
  list<Y> ys_;
  X x;
  Y y;
algorithm
  zs := match (xs,ys)
    case ({}   ,  _)    then {};
    case (_    , {})    then {};
    case (x::xs_, y::ys_) then (x,y) :: listZip(xs_,ys_);
  end match;
end listZip;

function varString
  input MidCode.Var var;
  output String str;
algorithm
  str := "(" + DAEDump.daeTypeStr(var.ty) + ") " + var.name;
end varString;

function dumpProgram
  input MidCode.Program iProgram;
  output String textString;
algorithm
  textString := Tpl.tplString(MidCodeDump.dumpProgram, iProgram);
end dumpProgram;

function outVarToVar
  input MidCode.OutVar outVar;
  output MidCode.Var var;
algorithm
  MidCode.OUT_VAR(var) := outVar;
end outVarToVar;

function encodeIdentifierDotPath
"Encodes a absynPath dot path according to the scheme used by codegen."
  input Absyn.Path p;
  output String pStr;
algorithm
  pStr := Tpl.textString(CodegenUtil.dotPath(Tpl.MEM_TEXT({},{}), p));
end encodeIdentifierDotPath;

function encodeIdentifierUnderscorePath
"Encodes a absynPath to a underscore path according to the scheme used by codegen."
  input Absyn.Path p;
  output String pStr;
algorithm
  pStr := Tpl.textString(CodegenUtil.underscorePath(Tpl.MEM_TEXT({},{}), p));
end encodeIdentifierUnderscorePath;

function getArrayAllocaCall
  input DAE.Type ty;
  output String functionName;
algorithm
  functionName := match ty
    case DAE.T_REAL(__) then "alloc_real_array";
    else
    algorithm
      Error.addInternalError("getArrayAllocaCall" , sourceInfo());
      then fail(); //TODO add more types.
  end match;
end getArrayAllocaCall;

function getArrayType
  "Given an inty from an array returns the scalar type of the array."
  input DAE.Type inty;
  output DAE.Type outTy;
algorithm
  outTy := match inty
    case DAE.T_ARRAY(__) then inty.ty;
    case DAE.T_METAARRAY(__) then inty.ty;
    else algorithm Error.addInternalError("Erranous parameter passed to getArrayType\n", sourceInfo());
      then fail();
  end match;
end getArrayType;

annotation(__OpenModelica_Interface="backendInterface");
end MidCodeUtil;