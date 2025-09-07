from sentence_transformers import SentenceTransformer, util

sentence = "What are the best food specialties in Göteborg?"

# Loading pre-trained model
model = SentenceTransformer("all-MiniLM-L6-v2")

# Encoding sentences into vectors
vect = model.encode(sentence)

print(f"Vector : {vect} of type {type(vect)} with {len(vect)} dimensions")
