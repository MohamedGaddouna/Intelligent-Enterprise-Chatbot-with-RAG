📄🤖 Intelligent Enterprise Chatbot (RAG)

This project is a document-based Q&A chatbot built with Flutter (frontend) and FastAPI + Python (backend).
Users can upload a PDF file and ask questions, and the system uses a free local LLM (GPT-2) to generate responses based on the document's content.

✨ Features

📤 PDF Upload from the Flutter app

📚 PDF Text Extraction using PyPDF2

❓ Question Answering based on document context

🤖 Local LLM (GPT-2) for text generation

💬 Chat Interface with user/bot messages

⚡ Fast Backend with FastAPI

🛠️ Technologies Used
🎨 Frontend

Flutter (Dart)

HTTP client

🧠 Backend

FastAPI (Python)

PyPDF2 (PDF processing)

Hugging Face Transformers (GPT-2)

🔍 How It Works

📄 The user uploads a PDF

🧩 The backend extracts text from the document

❓ The user asks a question

🤖 GPT-2 generates an answer using the document text as context

💬 The answer is returned to the Flutter chat interface
▶️ Running the Backend
cd ai_document_assistant_backend
pip install -r requirements.txt
uvicorn app:app --reload

▶️ Running the Flutter App
cd ai_document_assistant
flutter pub get
flutter run
🎯 Purpose of the Project

This project demonstrates:

🔗 Integration between Flutter and Python

🧠 Using a local free LLM (no API key required)

📄 Building a simple RAG pipeline

🏗️ Client–server architecture

💬 Real-time Q&A with a modern interface

🚀 Future Improvements

Add vector search (FAISS)

Use a stronger open LLM (LLaMA-3, Mistral, Qwen)

Add authentication
