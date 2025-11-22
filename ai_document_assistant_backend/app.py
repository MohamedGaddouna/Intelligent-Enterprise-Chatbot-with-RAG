# app.py
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from rag import process_pdf, ask_question

app = FastAPI()

# Autoriser Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

pdf_text = ""  # stockage du contenu PDF


@app.post("/upload")
async def upload_pdf(file: UploadFile = File(...)):
    global pdf_text

    content = await file.read()
    text = process_pdf(content)

    if not text.strip():
        return {"message": "Le fichier PDF est vide ou illisible."}

    pdf_text = text
    return {"message": "Fichier téléchargé avec succès."}


@app.post("/ask")
async def ask(question: str = Form(...)):
    global pdf_text

    if not pdf_text:
        return {"answer": "Aucun document n'a été chargé."}

    answer = ask_question(question, pdf_text)
    return {"answer": str(answer)}
