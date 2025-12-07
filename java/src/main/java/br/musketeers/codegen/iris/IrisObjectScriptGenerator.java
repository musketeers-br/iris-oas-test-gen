/// based on https://www.baeldung.com/java-openapi-custom-generator
/// https://github.com/OpenAPITools/openapi-generator/blob/master/modules/openapi-generator/src/main/java/org/openapitools/codegen/DefaultCodegen.java
package br.musketeers.codegen.iris;

import org.openapitools.codegen.*;
import org.openapitools.codegen.model.*;
import io.swagger.models.properties.*;

import java.util.*;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

public class IrisObjectScriptGenerator extends DefaultCodegen implements CodegenConfig {

    // source folder where to write the files
    // protected String sourceFolder = "src";
    protected String sourceFolder = ".";
    protected String apiVersion = "1.0.0";
    // The key that was used in the CLI: --additional-properties x-musketeers-package-name=...
    public static final String MY_CUSTOM_PACKAGE_NAME = "x-musketeers-package-name";
    // The package name of the generated classes
    public String packageName = "mypackage";

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
    
    @Override
    public String modelPackage() {
        return packageName + "." + modelPackage;
    }

    @Override
    public String apiPackage() {
        return packageName + "." + apiPackage;
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
        typeMapping.put("array", "%ListOfObjects"); 
        typeMapping.put("file", "%Stream.FileBinary"); 
        // Add more as needed, e.g., for arrays

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
        additionalProperties.put(MY_CUSTOM_PACKAGE_NAME, packageName);

        // /**
        //  * Supporting Files.  You can write single files for the generator with the
        //  * entire object tree available.  If the input file has a suffix of `.mustache
        //  * it will be processed by the template engine.  Otherwise, it will be copied
        //  *
        // */
        // supportingFiles.add();
        
        // /**
        //  * Supporting Files.  You can write single files for the generator with the
        //  * entire object tree available.  If the input file has a suffix of `.mustache
        //  * it will be processed by the template engine.  Otherwise, it will be copied
        //  */
        // supportingFiles.add(new SupportingFile("myFile.mustache",   // the input template or file
        // "",                                                       // the destination folder, relative `outputFolder`
        // "myFile.sample")                                          // the output file
        // );

        // /**
        //  * Language Specific Primitives.  These types will not trigger imports by
        //  * the client generator
        //  */
        // languageSpecificPrimitives = new HashSet<String>(
        //     Arrays.asList(
        //         "Type1",      // replace these with your types
        //         "Type2")
        // );
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
        char sep = File.separatorChar;
        return outputFolder + sep + sourceFolder + sep + modelPackage().replace('.', sep);
    }

    /**
     * Location to write api files.  You can use the apiPackage() as defined when the class is
     * instantiated
     */
    @Override
    public String apiFileFolder() {
        char sep = File.separatorChar;
        return outputFolder + sep + sourceFolder + sep + apiPackage().replace('.', sep);
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

    @Override
    @SuppressWarnings("unused")
    public void postProcessParameter(CodegenParameter parameter) {
    }
    
    @Override
    @SuppressWarnings("unused")
    public void postProcessModelProperty(CodegenModel model, CodegenProperty property) {
        // 1. Mapeamento de Tipos com Formato Específico (DateTime, Date)
        // O CodegenProperty já traduziu o 'type' base, mas o 'format' nos permite refinar.

        if (property.dataFormat != null) {
            switch (property.dataFormat.toLowerCase()) {
                case "date-time":
                    // Exemplo: {"type":"string", "format":"date-time"} -> %DateTime
                    property.dataType = "%DateTime";
                    
                    // Adiciona uma extensão para facilitar a identificação no template (opcional, mas útil)
                    property.vendorExtensions.put("x-is-datetime", true);
                    break;
                    
                case "date":
                    // Exemplo: {"type":"string", "format":"date"} -> %Date
                    property.dataType = "%Date";
                    property.vendorExtensions.put("x-is-date", true);
                    break;
                    
                case "double":
                case "float":
                    // Exemplo: {"type":"number", "format":"double"} ou {"type":"number", "format":"float"} -> %Double
                    property.dataType = "%Double";
                    property.vendorExtensions.put("x-is-double", true);
                    break;

                case "binary":
                    // Exemplo: {"type":"string", "format":"binary"} -> %Stream.GlobalBinary ou %Binary
                    // Dependendo do seu estilo de codificação em IRIS
                    property.dataType = "%Stream.GlobalBinary"; 
                    property.vendorExtensions.put("x-is-binary", true);
                    break;

                // Você pode adicionar mais casos para outros formatos como "uuid", etc.
            }
        }

        // 2. Mapeamento de Tipos Base (que podem não ter 'format' definido)
        // Se o 'dataType' ainda for o mapeamento padrão de 'string', podemos refinar.
        
        // Se a propriedade é um array (list), precisamos garantir que o tipo do item seja processado
        if (property.isContainer && property.items != null) {
            // Isso garantirá que o tipo dentro da lista, se aplicável, seja processado
            // (Embora o OpenAPI Generator geralmente faça isso em etapas anteriores, é uma boa prática verificar)
            postProcessModelProperty(model, property.items);
        }
        
        // Exemplo de Mapeamento Adicional/Default (caso não tenha sido tratado no typeMapping)
        if ("integer".equalsIgnoreCase(property.dataType) && property.dataFormat == null) {
            property.dataType = "%Integer";
        } else if ("boolean".equalsIgnoreCase(property.dataType) && property.dataFormat == null) {
            property.dataType = "%Boolean";
        }
        // Nota: Os tipos básicos como String, Integer, etc., geralmente são mapeados em typeMapping(). 
        // Esta função foca primariamente em refinar pelo 'format'.
    }
    
    // A common place to access and use custom properties is 
    // in the postProcess* methods, but you can also use them 
    // in methods that configure file generation, like:
    @Override
    public void processOpts() {
        super.processOpts(); // IMPORTANT: Always call the super method first.
        
        // 1. Check if the property exists in the map
        if (additionalProperties.containsKey(MY_CUSTOM_PACKAGE_NAME)) {
            
            // 2. Retrieve the value and cast it to String
            String customPackage = (String) additionalProperties.get(MY_CUSTOM_PACKAGE_NAME);
            
            // 3. Use the value, for example, to set a standard package variable
            packageName = customPackage;

            char sep = File.separatorChar;

            /**
             * Supporting Files.  You can write single files for the generator with the
             * entire object tree available.  If the input file has a suffix of `.mustache
             * it will be processed by the template engine.  Otherwise, it will be copied
             */
            supportingFiles.add(
                new SupportingFile(
                    "HttpUtils.mustache",   // the input template or file
                    "", // the destination folder, relative `outputFolder`
                    sourceFolder + sep + packageName.replace('.', sep) + "/utils/HttpUtils.cls" // the output file
                )
            );
        } else {
            // Optional: Handle case where property is not passed
            System.out.println("WARN: Custom package name not set. Using default.");
        }
    }

}