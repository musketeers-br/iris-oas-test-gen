package br.musketeers.codegen.iris;

import org.openapitools.codegen.*;
import org.openapitools.codegen.model.*;
import io.swagger.models.properties.*;

import java.util.*;
import java.io.File;

public class IrisObjectScriptGenerator extends DefaultCodegen implements CodegenConfig {

    // source folder where to write the files
    protected String sourceFolder = "src";
    protected String apiVersion = "1.0.0";

    /**
     * Configures the type of generator.
     *
     * @return  the CodegenType for this generator
     * @see     org.openapitools.codegen.CodegenType
     */
    public CodegenType getTag() {
        return CodegenType.OTHER;
    }

    /**
     * Configures a friendly name for the generator.  This will be used by the generator
     * to select the library with the -g flag.
     *
     * @return the friendly name for the generator
     */
    public String getName() {
        return "iris-object-script";
    }

    /**
     * Provides an opportunity to inspect and modify operation data before the code is generated.
     */
    @Override
    public OperationsMap postProcessOperationsWithModels(OperationsMap objs, List<ModelMap> allModels) {
        // Calling super ensures default processing occurs
        OperationsMap results = super.postProcessOperationsWithModels(objs, allModels);

        OperationMap ops = results.getOperations();
        List<CodegenOperation> opList = ops.getOperation();

        // iterate over the operation and perhaps modify something
        for(CodegenOperation co : opList){
            // example:
            // co.httpMethod = co.httpMethod.toLowerCase();
        }

        return results;
    }

    /**
     * Returns human-friendly help for the generator.  Provide the consumer with help
     * tips, parameters here
     *
     * @return A string value for the help message
     */
    public String getHelp() {
        return "Generates an iris-object-script client library.";
    }

    public IrisObjectScriptGenerator() {
        super();

        // set the output folder here
        outputFolder = "generated-code/iris-object-script";

        // Set the InterSystems IRIS type mappings
        typeMapping.put("string", "%String");
        typeMapping.put("integer", "%Integer");
        typeMapping.put("long", "%BigInt"); // for format: int64
        typeMapping.put("boolean", "%Boolean");
        typeMapping.put("number", "%Double");
        typeMapping.put("float", "%Double");
        typeMapping.put("double", "%Double");
        typeMapping.put("date", "%Date");
        typeMapping.put("date-time", "%TimeStamp");
        typeMapping.put("password", "%String");
        typeMapping.put("byte", "%String");
        // Add more as needed, e.g., for arrays
        // typeMapping.put("array", "%ListOfObjects"); 
        
        // Customize your date/datetime format if necessary for IRIS Date/Time handling
        // dateLibrary = "iris"; // Example, might need custom implementation

        /**
         * Models.  You can write model files using the modelTemplateFiles map.
         * if you want to create one template for file, you can do so here.
         * for multiple files for model, just put another entry in the `modelTemplateFiles` with
         * a different extension
         */
        modelTemplateFiles.put(
            "model.mustache", // the template to use
            ".cls");       // the extension for each file to write

        /**
         * Api classes.  You can write classes for each Api file with the apiTemplateFiles map.
         * as with models, add multiple entries with different extensions for multiple files per
         * class
         */
        apiTemplateFiles.put(
            "api.mustache",    // the template to use
            ".cls");        // the extension for each file to write

        /**
         * Template Location.  This is the location which templates will be read from.  The generator
         * will use the resource stream to attempt to read the templates.
         */
        templateDir = "iris-object-script";

        /**
         * Api Package.  Optional, if needed, this can be used in templates
         */
        apiPackage = "api";

        /**
         * Model Package.  Optional, if needed, this can be used in templates
         */
        modelPackage = "model";

        // /**
        //  * Reserved words.  Override this with reserved words specific to your language
        //  */
        // reservedWords = new HashSet<String> (
        // Arrays.asList(
        //     "sample1",  // replace with static values
        //     "sample2")
        // );

        /**
         * Additional Properties.  These values can be passed to the templates and
         * are available in models, apis, and supporting files
         */
        additionalProperties.put("apiVersion", apiVersion);

        // /**
        //  * Supporting Files.  You can write single files for the generator with the
        //  * entire object tree available.  If the input file has a suffix of `.mustache
        //  * it will be processed by the template engine.  Otherwise, it will be copied
        //  */
        // supportingFiles.add(new SupportingFile("myFile.mustache",   // the input template or file
        // "",                                                       // the destination folder, relative `outputFolder`
        // "myFile.sample")                                          // the output file
        // );

        /**
         * Language Specific Primitives.  These types will not trigger imports by
         * the client generator
         */
        languageSpecificPrimitives = new HashSet<String>(
            Arrays.asList(
                "Type1",      // replace these with your types
                "Type2")
        );
    }

  /**
   * Escapes a reserved word as defined in the `reservedWords` array. Handle escaping
   * those terms here.  This logic is only called if a variable matches the reserved words
   *
   * @return the escaped term
   */
    @Override
    public String escapeReservedWord(String name) {
    return "_" + name;  // add an underscore to the name
    }

    /**
     * Location to write model files.  You can use the modelPackage() as defined when the class is
     * instantiated
     */
    public String modelFileFolder() {
        return outputFolder + "/" + sourceFolder + "/" + modelPackage().replace('.', File.separatorChar);
    }

    /**
     * Location to write api files.  You can use the apiPackage() as defined when the class is
     * instantiated
     */
    @Override
    public String apiFileFolder() {
        return outputFolder + "/" + sourceFolder + "/" + apiPackage().replace('.', File.separatorChar);
    }

    /**
     * override with any special text escaping logic to handle unsafe
     * characters so as to avoid code injection
     *
     * @param input String to be cleaned up
     * @return string with unsafe characters removed or escaped
     */
    @Override
    public String escapeUnsafeCharacters(String input) {
        //TODO: check that this logic is safe to escape unsafe characters to avoid code injection
        return input;
    }

    /**
     * Escape single and/or double quote to avoid code injection
     *
     * @param input String to be cleaned up
     * @return string with quotation mark removed or escaped
     */
    public String escapeQuotationMark(String input) {
        //TODO: check that this logic is safe to escape quotation mark to avoid code injection
        return input.replace("\"", "\\\"");
    }
    
    @Override
    public String toModelName(String name) {
        // 1. Apply default naming conventions (e.g., capitalizing the name)
        String modelName = super.toModelName(name); 
    
        // 2. Check if it's a language primitive (like %String), if not, prepend package.
        if (modelName != null && !modelName.isEmpty() && !languageSpecificPrimitives.contains(modelName)) {
            
            // This is the model package you configure (e.g., "dc.Sample.Client")
            // The result is "dc.Sample.Client.Person"
            return modelPackage() + "." + modelName; 
        }
        return modelName;
    }

}