-- Turn external REST endpoint invocation ON in the database
EXECUTE sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE WITH OVERRIDE;
GO

-- Create a master key for the database
IF NOT EXISTS (SELECT *
               FROM sys.symmetric_keys
               WHERE [name] = '##MS_DatabaseMasterKey##')
    BEGIN
        CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'<password>';
    END
GO

-- Create access credentials to Azure OpenAI using a key:
CREATE DATABASE SCOPED CREDENTIAL [https://my-azure-openai-endpoint.openai.azure.com/]
    WITH IDENTITY = 'HTTPEndpointHeaders', secret = '{"api-key":"YOUR_AZURE_OPENAI_KEY"}';
GO

-- Create an external model to call the Azure OpenAI embeddings REST endpoint
CREATE EXTERNAL MODEL MyAzureOpenAiModel
WITH (
      LOCATION = 'https://my-azure-openai-endpoint.openai.azure.com/openai/deployments/text-embedding-ada-002/embeddings?api-version=2023-05-15',
      API_FORMAT = 'Azure OpenAI',
      MODEL_TYPE = EMBEDDINGS,
      MODEL = 'text-embedding-ada-002',
      CREDENTIAL = [https://my-azure-openai-endpoint.openai.azure.com/]
);

-- Create a table with text to chunk and insert data
CREATE TABLE textchunk
(
    text_id INT IDENTITY (1, 1) PRIMARY KEY,
    text_to_chunk NVARCHAR (MAX)
);
GO

INSERT INTO textchunk (text_to_chunk)
VALUES
('All day long we seemed to dawdle through a country which was full of beauty of every kind. Sometimes we saw little towns or castles on the top of steep hills such as we see in old missals; sometimes we ran by rivers and streams which seemed from the wide stony margin on each side of them to be subject to great floods.'),
('My Friend, Welcome to the Carpathians. I am anxiously expecting you. Sleep well to-night. At three to-morrow the diligence will start for Bukovina; a place on it is kept for you. At the Borgo Pass my carriage will await you and will bring you to me. I trust that your journey from London has been a happy one, and that you will enjoy your stay in my beautiful land. Your friend, DRACULA')
GO

-- Create a new table to hold the chunked text and vector embeddings
CREATE TABLE text_embeddings
(
    embeddings_id INT IDENTITY (1, 1) PRIMARY KEY,
    chunked_text NVARCHAR (MAX),
    vector_embeddings VECTOR (1536)
);

-- Insert the chunked text and vector embeddings into the text_embeddings table using AI_GENERATE_CHUNKS and AI_GENERATE_EMBEDDINGS
INSERT INTO text_embeddings (chunked_text, vector_embeddings)
SELECT c.chunk, AI_GENERATE_EMBEDDINGS(c.chunk USE MODEL MyAzureOpenAiModel)
FROM textchunk t
CROSS APPLY
    AI_GENERATE_CHUNKS(source = t.text_to_chunk, chunk_type = FIXED, chunk_size = 100) c;

-- View the results
SELECT * FROM text_embeddings;