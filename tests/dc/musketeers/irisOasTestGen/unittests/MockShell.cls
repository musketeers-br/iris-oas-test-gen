Class dc.musketeers.irisOasTestGen.unittests.MockShell Extends dc.musketeers.irisOasTestGen.SystemShell
{

Property ExecuteExitCode As %Integer [ InitialExpression = 0 ];

Property ExecuteProgram As %String;

Property ExecuteArgs As %String(MAXLEN = "");

Property ExecuteFlags As %String;

Property ExecuteCallCount As %Integer [ InitialExpression = 0 ];

/// Simulate the execution, capturing arguments and returning a set exit code.
Method Execute(flags As %String, program As %String, args...) As %Integer
{
    Set ..ExecuteCallCount = ..ExecuteCallCount + 1
    Set ..ExecuteFlags = flags
    Set ..ExecuteProgram = program
    
    // Capture all arguments into a single string for verification
    Set ..ExecuteArgs = " "
    Set i = 1
    While $Data(args(i)) {
        If ..ExecuteArgs '= "" Set ..ExecuteArgs = ..ExecuteArgs _ " "
        Set ..ExecuteArgs = ..ExecuteArgs _ args(i)
        Set i = i + 1
    }
    
    Return ..ExecuteExitCode
}

}
