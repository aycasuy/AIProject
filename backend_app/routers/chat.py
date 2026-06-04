import hashlib
import json

from fastapi import APIRouter, HTTPException , Depends, types
from google import genai
import models
from routers.user import get_db
from database import SessionLocal
import schemas
import config
from routers.ai_service import get_smart_ai_response
from routers import ai_service
from sqlalchemy.orm import Session


router = APIRouter()

# Yeni nesil Gemini İstemcisi (Client)
client = genai.Client(api_key=config.GOOGLE_API_KEY)


@router.post("/chat")
async def chat_with_ai(request: schemas.ChatRequest , db: Session = Depends(get_db) ):
    try:
        prompt = f"""
        Sen uzman, sabırlı ve cesaretlendirici bir {request.target_language} öğretmenisin. Öğrencin seninle {request.target_language} öğrenmek ve pratik yapmak istiyor.
        Öğrencinin ana dili: {request.native_language}.

        Sana gönderdiği her mesajda şu İKİ KURALA kesinlikle uymak zorundasın:

        KURAL 1 (ÖĞRETME VE DÜZELTME - {request.native_language} DİLİNDE): 
        Öğrencinin mesajında gramer, kelime, zaman (tense) veya yazım hatası varsa, bir öğretmen gibi devreye gir. Hatayı {request.native_language} dilinde çok nazikçe açıkla ve cümlenin DOĞRU halini öğret. 
        Eğer mesajı kusursuzsa "Harika! Cümlen tamamen doğru." şeklinde {request.native_language} dilinde kısa bir tebrik et.
    
        KURAL 2 (SOHBETE DEVAM - {request.target_language} DİLİNDE): 
        Düzeltme ve öğretme faslı bittikten hemen sonra, sohbete doğal bir şekilde {request.target_language} dilinde devam et. Konuşmanın akması için ona mutlaka {request.target_language} dilinde yeni bir soru sor.

        Cevaplarını her zaman birebir şu formatta ver (Emojileri ve satır başlarını mutlaka koru):
        💡 Düzeltme: [{request.native_language} dilinde hatanın açıklaması, doğrusunun öğretilmesi veya tebrik]
        💬 Öğretmen: [{request.target_language} dilinde sohbet mesajın ve yeni sorun]
        """
        
        full_prompt = f"{prompt}\n\nÖğrencinin Mesajı: {request.user_input}"
        
        
        ai_cevabi = await get_smart_ai_response(
        db=db,
        feature_type="chat", # Burası önemli, her sayfa için farklı bir isim ver
        user_input=request.user_input, 
        system_prompt=full_prompt
        )
    
        return {"response": ai_cevabi}

    except Exception as e:
        print("Chat Hatası:", str(e))
        raise HTTPException(status_code=500, detail="Chat yapılırken bir hata oluştu.")


