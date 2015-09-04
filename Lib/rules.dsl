:default ::= action => [name,values]
lexeme default = latm => 1

Script ::= 
    Definition 
    |Script Definition 

Definition ::= ExpDef | ParamDef |  RulDef | MapDef | DatDef

MapDef ::= 'MAP' InfoVar '->' cdec action => add_map
 
RulDef ::= 
     rdec step ':' 'WHEN' InfoVar 'THEN' InfoVar action => add_rule_step
    |rdec step ':' 'ELSE' InfoVar action => add_last_rule_step

ExpDef ::= edec ':' ComExp action => add_exp
ParamDef ::= pdec ':'  Value1 ',' Value2 action => add_param

DatDef ::= 
    dsdec ':' DataSet action => add_dataset
    |DatDef cdec ':' ColumnName action => add_col

ComExp ::= 
    Term Operator Term action => found_Exp 
    |ComExp Operator Term action => found_Exp

Term ::= InfoVar action => found_Term 
        | '(' Exp ')' action => found_SubTerm

Exp ::= 
    InfoVar Operator InfoVar action => found_Exp
     |Exp Operator InfoVar action => found_Exp
   

InfoVar ::= pdec action => found_InfoVar
        | cdec   action => found_InfoVar
        | edec   action => found_InfoVar 
        | rdec   action => found_InfoVar
        | dsdec  action => found_InfoVar

rdec ~ 'Rul' num
pdec ~ 'Par' num 
cdec ~ 'Col' num 
edec ~ 'Exp' num 
step ~ '.s' num
dsdec ~ 'Dat' num 

num ~ [\d]+

Operator ~ MathOp | LogOp
MathOp ~ [\+\*\-\/]
LogOp ~ 'AND' | 'OR' | '<' | '>' | '=' | 'IN'

Value1 ~ Anum
Value2 ~ Anum
ColumnName ~ Anum
DataSet ~ Anum

Anum ~ [\w]+

:discard ~ whitespace
whitespace ~ [\s]+
