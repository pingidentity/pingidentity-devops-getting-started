package com.pingidentity.apac.pf.bulkconfigtools;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.ParseException;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;
import java.util.Scanner;

import org.json.JSONArray;
import org.json.JSONObject;

public class App {

	private final static String DEFAULT_IN_CONFIG = "in/pf-config.json";
	private final static String DEFAULT_IN_BULKCONFIG = "in/pf-export.json";
	private final static String DEFAULT_IN_ENVPROPERTIES = "in/out-pf-env.properties";
	private final static String DEFAULT_IN_OUTCONFIG = "in/out-pf-bulk-config.json";

	private final JSONObject inConfigJSON;
	private final JSONArray inConfigExposeParametersArray;
	private final JSONArray inConfigRemoveConfig;
	private final JSONArray inConfigAddConfig;
	private final JSONArray inConfigChangeValue;
	private final JSONArray inConfigAliases;
	private final JSONObject inBulkJSON;

	private final Properties returnProperties = new Properties();

	private final String envFileName, outJSON;

	public static void main(String [] args) throws ParseException, IOException, RemoveNodeException
	{
		App app = null;
		if(args.length > 3)
			app = new App(args[0], args[1], args[2], args[3]);
		else
			app = new App();

		app.writeEnvFile();
		app.writeBulkConfigFile();


	}

	public App(String inConfigFile, String inBulkFile, String inEnvPropertiesFile, String outJSON) throws ParseException, IOException, RemoveNodeException
	{
		this.inConfigJSON = convertFileToJSON(inConfigFile);
		this.inConfigExposeParametersArray = this.inConfigJSON.has("expose-parameters")? (JSONArray) this.inConfigJSON.get("expose-parameters"): null;
		this.inConfigRemoveConfig = this.inConfigJSON.has("remove-config")? (JSONArray) this.inConfigJSON.get("remove-config"): null;
		this.inConfigAddConfig = this.inConfigJSON.has("add-config")? (JSONArray) this.inConfigJSON.get("add-config"): null;
		this.inConfigChangeValue = this.inConfigJSON.has("change-value")? (JSONArray) this.inConfigJSON.get("change-value"): null;
		this.inConfigAliases = this.inConfigJSON.has("config-aliases")? (JSONArray) this.inConfigJSON.get("config-aliases"): null;
		this.inBulkJSON = getReplacedJSONObject(inBulkFile, this.inConfigJSON);
		this.envFileName = inEnvPropertiesFile;
		this.outJSON = outJSON;

		loadProperties();

		processBulkJSON();
	}

	public App() throws ParseException, IOException, RemoveNodeException
	{
		this.inConfigJSON = convertFileToJSON(DEFAULT_IN_CONFIG);
		this.inConfigExposeParametersArray = this.inConfigJSON.has("expose-parameters")? (JSONArray) this.inConfigJSON.get("expose-parameters"): null;
		this.inConfigRemoveConfig = this.inConfigJSON.has("remove-config")? (JSONArray) this.inConfigJSON.get("remove-config"): null;
		this.inConfigAddConfig = this.inConfigJSON.has("add-config")? (JSONArray) this.inConfigJSON.get("add-config"): null;
		this.inConfigChangeValue = this.inConfigJSON.has("change-value")? (JSONArray) this.inConfigJSON.get("change-value"): null;
		this.inConfigAliases = this.inConfigJSON.has("config-aliases")? (JSONArray) this.inConfigJSON.get("config-aliases"): null;
		this.inBulkJSON = getReplacedJSONObject(DEFAULT_IN_BULKCONFIG, this.inConfigJSON);
		this.envFileName = DEFAULT_IN_ENVPROPERTIES;
		this.outJSON = DEFAULT_IN_OUTCONFIG;

		loadProperties();

		processBulkJSON();
	}

	private void processBulkJSON() throws RemoveNodeException {

		if(this.inConfigExposeParametersArray != null)
			processBulkJSONNode("", this.inBulkJSON, null, null);
	}

	private void processBulkJSONNode(String path, JSONObject jsonObject, JSONObject parentObject, JSONArray arrayPeers) throws RemoveNodeException {

		processRemoveConfig(jsonObject);
		processChangeValue(jsonObject);

		if(jsonObject.has("resourceType"))
			path = String.valueOf(jsonObject.get("resourceType")).replace("/", "_").substring(1);

		if(jsonObject.has("id"))
			path = path + "_" + getEscapedValue(String.valueOf(jsonObject.get("id")));

		System.out.println("Path: " + path);

		processExposeConfig(path, jsonObject, parentObject, arrayPeers);

		for(String key : jsonObject.keySet())
		{
			if(jsonObject.get(key) instanceof JSONObject)
			{
				JSONObject currentJSON = (JSONObject) jsonObject.get(key);

				String newPath = path + "_" + key;

				try
				{
					processBulkJSONNode(newPath, currentJSON, jsonObject, null);
				}catch(RemoveNodeException e)
				{
					jsonObject.remove(key);
				}
			}
			else if(jsonObject.get(key) instanceof JSONArray)
			{
				String newPath = path + "_" + key;

				JSONArray jsonArray = (JSONArray) jsonObject.get(key);

				JSONArray newJSONArray = new JSONArray();

				for(Object currentObject : jsonArray)
				{
					if(currentObject instanceof JSONObject)
					{
						try
						{
							processBulkJSONNode(newPath, (JSONObject) currentObject, jsonObject, jsonArray);
							newJSONArray.put(currentObject);

						}catch(RemoveNodeException e)
						{
						}
					}
					else
						newJSONArray.put(currentObject);
				}

				processAddConfig(newPath, newJSONArray);

				jsonObject.put(key, newJSONArray);
			}
		}


	}

	private void processRemoveConfig(JSONObject jsonObject) throws RemoveNodeException
	{
		if(this.inConfigRemoveConfig != null)
		{
			for(Object configObject : this.inConfigRemoveConfig)
			{
				JSONObject configJSON = (JSONObject) configObject;

				String key = String.valueOf(configJSON.get("key"));
				String value = String.valueOf(configJSON.get("value"));

				if(jsonObject.has(key))
				{
					String jsonValue = String.valueOf(jsonObject.get(key));

					if(jsonValue.equals(value) || jsonValue.matches(value))
					{
						System.out.println("Ignoring " + key + ":" + value);
						throw new RemoveNodeException();
					}
				}

			}
		}
	}

	private void processAddConfig(String path, JSONArray jsonArray) throws RemoveNodeException
	{
		if(this.inConfigAddConfig != null)
		{
			for(Object configObject : this.inConfigAddConfig)
			{
				JSONObject configJSON = (JSONObject) configObject;

				if(!configJSON.has("item") && !configJSON.has("resourceType"))
				{
					System.out.println("Bad config for add-config: " + configJSON.toString(4));
					continue;
				}

				String resourceType = String.valueOf(configJSON.get("resourceType"));

				if(!path.endsWith("_" + resourceType))
					continue;

				JSONObject newObject = (JSONObject) configJSON.get("item");
				jsonArray.put(newObject);

			}
		}
	}

	private void processChangeValue(JSONObject jsonObject)
	{
		if(this.inConfigChangeValue != null)
		{
			for(Object configObject : this.inConfigChangeValue)
			{
				JSONObject configJSON = (JSONObject) configObject;

				String key = String.valueOf(configJSON.get("parameter-name"));

				JSONObject matchingIdentifier = (JSONObject) configJSON.get("matching-identifier");
				String matchingName = String.valueOf(matchingIdentifier.get("id-name"));
				String matchingValue = String.valueOf(matchingIdentifier.get("id-value"));

				if(jsonObject.has(matchingName) && jsonObject.get(matchingName).equals(matchingValue))
				{
					Object newValue = configJSON.get("new-value");
					jsonObject.put(key, newValue);
				}

			}
		}
	}

	private void processExposeConfig(String path, JSONObject jsonObject, JSONObject parentObject, JSONArray arrayPeers)
	{

		if(this.inConfigExposeParametersArray != null)
		{
			for(Object configObject : this.inConfigExposeParametersArray)
			{
				JSONObject configJSON = (JSONObject) configObject;

				String parameterName = String.valueOf(configJSON.get("parameter-name"));

				if(jsonObject.has(parameterName))
				{
					String replaceName = parameterName;
					String replaceValue = "";

					if(configJSON.has("replace-name"))
					{
						replaceName = String.valueOf(configJSON.get("replace-name"));
						jsonObject.remove(parameterName);
					}
					else
						replaceValue = String.valueOf(jsonObject.get(parameterName));

					String currentIdentifier = getUniqueIdentifier(path, configJSON, jsonObject, parentObject, arrayPeers);

					if(currentIdentifier == null)
						continue;

					String propertyName = path + "_" + replaceName;
					if(!currentIdentifier.equals(""))
						propertyName = path + "_" + getEscapedValue(currentIdentifier) + "_" + getEscapedValue(replaceName);

					boolean isSetEnvVar = isSetEnvVar(propertyName);

					propertyName = getConfigAlias(propertyName);

					jsonObject.put(replaceName, "${" + propertyName + "}");

					if(isSetEnvVar && !returnProperties.containsKey(propertyName))
						returnProperties.put(propertyName, replaceValue);
				}
			}
		}
	}

	private boolean isSetEnvVar(String propertyName) {
		if(this.inConfigAliases == null)
			return true;

		for(Object currentAliasConfigObj : this.inConfigAliases)
		{
			JSONObject configAliasConfig = (JSONObject) currentAliasConfigObj;

			List<String> configNameList = getConfigNameList(configAliasConfig);

			if(!configNameList.contains(propertyName))
				continue;

			if(!configAliasConfig.has("is-apply-envfile"))
				return true;

			return configAliasConfig.getBoolean("is-apply-envfile");
		}

		return true;
	}

	private String getConfigAlias(String propertyName) {
		if(this.inConfigAliases == null)
			return propertyName;

		for(Object currentAliasConfigObj : this.inConfigAliases)
		{
			JSONObject configAliasConfig = (JSONObject) currentAliasConfigObj;

			List<String> configNameList = getConfigNameList(configAliasConfig);
			System.out.println("Looking for config aliase: " + propertyName + ", " + configNameList.get(0));

			if(!configNameList.contains(propertyName))
				continue;

			System.out.println("Found config aliase: " + propertyName);
			if(!configAliasConfig.has("replace-name"))
				return propertyName;
			System.out.println("New config aliase: " + configAliasConfig.getString("replace-name"));

			return configAliasConfig.getString("replace-name");
		}

		return propertyName;
	}

	private List<String> getConfigNameList(JSONObject configAliasConfig)
	{
		JSONArray configNames = (JSONArray) configAliasConfig.get("config-names");

		String joinedConfigNames = configNames.join(",").replace("\"", "");
		List<String> configNameList = Arrays.asList(joinedConfigNames.split(","));

		return configNameList;
	}

	private String getUniqueIdentifier(String path, JSONObject configJSON, JSONObject jsonObject, JSONObject parentObject, JSONArray arrayPeers) {

		if(configJSON.has("unique-identifiers"))
		{
			JSONArray uidArray = (JSONArray) configJSON.get("unique-identifiers");
			for(Object uidObj : uidArray)
			{
				String uidConfig = String.valueOf(uidObj);
				String uid = null;
				String expectedUIDValue = null;

				if(uidConfig.contains("="))
				{
					String[] uidConfigSplit = uidConfig.split("=");
					uid = uidConfigSplit[0];
					expectedUIDValue = uidConfigSplit[1];
				}
				else
					uid = uidConfig;

				String returnUidValue = null;
				
				if(arrayPeers != null)
				{
					if(getUIDFromPeer(arrayPeers, uid) != null)
						returnUidValue = getUIDFromPeer(arrayPeers, uid);
				}
				
				if(returnUidValue == null)
				{
					if(arrayPeers == null && jsonObject.has(uid))
						returnUidValue = String.valueOf(jsonObject.get(uid));
					else if(parentObject != null && parentObject.has(uid))
						returnUidValue = String.valueOf(parentObject.get(uid));
				}
				
				if(expectedUIDValue != null && (returnUidValue == null || !returnUidValue.equals(expectedUIDValue)))
					return null;

				if(returnUidValue != null)
					return returnUidValue;
			}
			
			if(arrayPeers != null)
				return getUniqueIdentifier(path, configJSON, jsonObject, parentObject, null);
			
			return "";
		}

		return null;
	}

	private String getUIDFromPeer(JSONArray arrayPeers, String uid) {
		
		if(arrayPeers == null)
			return null;
		
		if(!uid.contains("/"))
			return null;
		
		String searchComponent = uid.substring(0, uid.indexOf("/"));
		String peerClaimValue = uid.substring(uid.indexOf("/") + 1);
		
		if(!searchComponent.contains("~"))
			return null;
		
		String [] searchComponentSplit = searchComponent.split("\\~");
		
		String searchName = searchComponentSplit[0];
		String searchNameValue = searchComponentSplit[1];
		
		for(Object currentPeer : arrayPeers)
		{
			JSONObject currentPeerJSON = (JSONObject) currentPeer;
			
			if(!currentPeerJSON.has(searchName))
				continue;
			
			String matchingValue = String.valueOf(currentPeerJSON.get(searchName));
			
			if(matchingValue != null && matchingValue.equals(searchNameValue))
				return getEscapedValue(searchNameValue + "_" + String.valueOf(currentPeerJSON.get(peerClaimValue)));
		}
		
		return null;
	}

	private String getEscapedValue(String in)
	{
		return in.replace(" ", "_").replace("-", "_").replace("|", "_").replace(":", "_").replace("\\.", "_");
	}

	private JSONObject getReplacedJSONObject(String fileName, JSONObject configuration) throws FileNotFoundException, ParseException
	{
		String jsonString = convertFileToString(fileName);

		JSONArray searchReplaceConfigs = configuration.has("search-replace")? (JSONArray) configuration.get("search-replace") : new JSONArray();

		for(Object searchReplaceConfig : searchReplaceConfigs)
		{
			JSONObject searchReplaceConfigJSON = (JSONObject) searchReplaceConfig;

			String search = String.valueOf(searchReplaceConfigJSON.get("search"));
			String replace = String.valueOf(searchReplaceConfigJSON.get("replace"));
			String applyEnvFileStr = String.valueOf(searchReplaceConfigJSON.get("apply-env-file"));
			Boolean isApplyEnvFile = Boolean.parseBoolean(applyEnvFileStr);


			jsonString = jsonString.replace(search, replace);

			if(isApplyEnvFile)
			{
				String propertyName = replace.replace("$", "").replace("{", "").replace("}", "");

				boolean isSetEnvVar = isSetEnvVar(propertyName);

				propertyName = getConfigAlias(propertyName);

				if(isSetEnvVar && !returnProperties.containsKey(propertyName))
					returnProperties.put(propertyName, search);
			}
		}

		JSONObject jsonObject = new JSONObject(jsonString);

		return jsonObject;
	}

	private JSONObject convertFileToJSON(String fileName) throws FileNotFoundException, ParseException {
		String jsonString = convertFileToString(fileName);

		JSONObject jsonObject = new JSONObject(jsonString);

		return jsonObject;
	}

	private String convertFileToString(String fileName) throws FileNotFoundException, ParseException {
		Scanner scanner = new Scanner(new File(fileName));

		String jsonString = scanner.useDelimiter("\\Z").next();

		scanner.close();

		return jsonString;
	}

	private void loadProperties() throws IOException {
		try {
			returnProperties.load(new FileInputStream(this.envFileName));
		} catch (FileNotFoundException e) {
			return;
		} catch (IOException e) {
			throw e;
		}
	}

	public void writeEnvFile() throws IOException {
		PrintWriter pw = new PrintWriter( this.envFileName );

		for(Object key : this.returnProperties.keySet())
		{
			String value = this.returnProperties.getProperty(String.valueOf(key), "");
			if(value.equals("null"))
				value = "";

			String finalValue = value.replaceAll("\\n", "").replaceAll("\\r", "").replaceAll("\\\\", "\\\\").replace("-----BEGIN CERTIFICATE-----", "").replace("-----END CERTIFICATE-----", "");
			pw.println(String.valueOf(key) + "=" + finalValue);
		}

		pw.close();

	}

	public void writeBulkConfigFile() throws IOException {
        FileOutputStream frBulkConfig = new FileOutputStream(this.outJSON);
        frBulkConfig.write(this.inBulkJSON.toString(4).getBytes());
        frBulkConfig.close();

	}
}
