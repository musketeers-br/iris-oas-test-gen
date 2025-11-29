/// Helper class to handle external shell execution, making the Main class testable.
Class dc.musketeers.irisOasTestGen.SystemShell Extends %RegisteredObject
{

/// Executes an external program using $ZF(-100).
/// This method should be called by the Main class.
/// 
/// Returns the exit code of the program.
Method Execute(pFlags As %String, pProgram As %String, pArgs...) As %Integer
{
	// The original $ZF call logic is now contained here.
	Set exitCode = $ZF(-100, pFlags, pProgram, pArgs...)
	
	Quit exitCode
}

}
