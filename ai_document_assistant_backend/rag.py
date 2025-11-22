# rag.py
from io import BytesIO
import PyPDF2
from transformers import pipeline

# Charger un modèle gratuit
generator = pipeline("text-generation", model="gpt2")

def process_pdf(file_content: bytes) -> str:
    """Extract text from PDF"""
    reader = PyPDF2.PdfReader(BytesIO(file_content))
    text = ""
    for page in reader.pages:
        p = page.extract_text()
        if p:
            text += p + "\n"
    return text


def ask_question(question: str, context: str) -> str:
    """Use a free LLM to answer the question using context"""
    prompt = f"Contexte:\n{context}\n\nQuestion: {question}\nRéponse:"

    try:
        output = generator(
            prompt,
            max_length=250,
            temperature=0.7,
            do_sample=True
        )

        full = output[0]["generated_text"]

        # Nettoyage
        answer = full.replace(prompt, "").strip()

        # Prendre une seule phrase pour Flutter
        if "." in answer:
            answer = answer.split(".")[0] + "."
        else:
            answer = answer[:200]

        # Si vide → réponse par défaut
        if len(answer) < 3:
            return "Je n'ai pas trouvé de réponse dans le document."

        return answer

    except Exception as e:
        return f"Erreur modèle : {str(e)}"
