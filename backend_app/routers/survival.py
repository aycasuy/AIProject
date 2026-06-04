# Rotaların (endpoint) arasına bunu ekle (Senin yapına göre @app veya @router kullan)


from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import bcrypt 
from routers.user import get_db
import models
from database import SessionLocal
from models import UserDB, UserProgressDB
import schemas

router = APIRouter()


@router.post("/decrease_life")
def decrease_life(request: schemas.DecreaseLifeRequest, db: Session = Depends(get_db)):
    user = db.query(models.UserDB).filter(models.UserDB.username == request.username).first()
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")

    progress = db.query(models.UserProgressDB).filter(
        models.UserProgressDB.user_id == user.id,
        models.UserProgressDB.target_language == request.target_language # 🌟 ARTIK DİNAMİK!
    ).first()

    if progress and progress.lives > 0:
        progress.lives -= 1
        # 🌟 KRİTİK: İlk defa can kaybediyorsa (5'ten 4'e düşüyorsa) 30 dakikalık sayacı başlat
        if progress.lives == 4 or progress.last_heart_lost is None:
            progress.last_heart_lost = datetime.now()
        
        db.commit()

    # 🌟 KRİTİK DÜZELTME: 'kalan_can' yerine 'remaining_lives' yaptık (Flutter bunu arıyor)
    return {
        "status": "success", 
        "message": "Can düşürüldü", 
        "remaining_lives": progress.lives if progress else 0
    }