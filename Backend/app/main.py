from fastapi import FastAPI, status, HTTPException, Request
from fastapi.staticfiles import StaticFiles 
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
import logging
import json
import os

# ==========================================
# CONFIGURATION DES CHEMINS ABSOLUS
# ==========================================
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATIC_DIR = os.path.join(BASE_DIR, "static")
TEMPLATES_DIR = os.path.join(BASE_DIR, "templates")
DB_FILE = os.path.join(BASE_DIR, "db.json")

# Créer les dossiers s'ils n'existent pas
os.makedirs(STATIC_DIR, exist_ok=True)
os.makedirs(TEMPLATES_DIR, exist_ok=True)

# ==========================================
# CONFIGURATION DU LOGGING
# ==========================================
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ==========================================
# CHARGEMENT DES DONNÉES
# ==========================================
def load_posts():
    """Charger les posts depuis db.json"""
    try:
        with open(DB_FILE, "r", encoding="utf-8") as file:
            data = json.load(file)
            posts = data.get("posts", [])
            logger.info(f"✅ {len(posts)} offres d'emploi chargées depuis {DB_FILE}")
            return posts
    except FileNotFoundError:
        logger.warning(f"⚠️  Fichier {DB_FILE} non trouvé")
        return []
    except json.JSONDecodeError as e:
        logger.error(f"❌ Erreur de décodage JSON dans {DB_FILE}: {e}")
        return []

posts = load_posts()

# ==========================================
# FONCTION HTTPS
# ==========================================
def https_url_for(request: Request, name: str, **path_params: any) -> str:
    """Convertir les URLs HTTP en HTTPS"""
    http_url = request.url_for(name, **path_params)
    https_url = str(http_url).replace("http", "https", 1)
    return https_url

# ==========================================
# CRÉATION DE L'APPLICATION FASTAPI
# ==========================================
app = FastAPI(
    title="Mahrasoft.com API",
    description="API pour le site web Mahrasoft Innovations",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# ==========================================
# MONTAGE DES FICHIERS STATIQUES
# ==========================================
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

# ==========================================
# CONFIGURATION DES TEMPLATES
# ==========================================
templates = Jinja2Templates(directory=TEMPLATES_DIR)
templates.env.globals["https_url_for"] = https_url_for

# ==========================================
# MIDDLEWARE CORS
# ==========================================
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================================
# MIDDLEWARE DE LOGGING DES REQUÊTES
# ==========================================
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Logger toutes les requêtes HTTP"""
    start_time = datetime.now()
    response = await call_next(request)
    process_time = (datetime.now() - start_time).total_seconds()
    
    logger.info(
        f"{request.method} {request.url.path} "
        f"- Status: {response.status_code} "
        f"- Time: {process_time:.3f}s"
    )
    
    return response

# ==========================================
# HEALTH CHECK ENDPOINTS
# ==========================================
@app.get("/health", tags=["Health"])
async def health_check():
    """Endpoint de santé pour Docker health check et monitoring"""
    return {
        "status": "healthy",
        "service": "Mahrasoft.com",
        "timestamp": datetime.now().isoformat(),
        "version": "1.0.0",
        "directories": {
            "base": BASE_DIR,
            "static": STATIC_DIR,
            "templates": TEMPLATES_DIR,
            "db_file": DB_FILE
        },
        "posts_count": len(posts)
    }

@app.get("/ping", tags=["Health"])
async def ping():
    """Simple ping endpoint pour vérifier que le service répond"""
    return {
        "status": "ok",
        "message": "pong",
        "timestamp": datetime.now().isoformat()
    }

# ==========================================
# PAGES PRINCIPALES
# ==========================================
@app.get("/", response_class=HTMLResponse, tags=["Pages"])
async def index(request: Request):
    """Page d'accueil"""
    return templates.TemplateResponse("index.html", {
        "request": request, 
        "current": "index"
    })

@app.get("/about", response_class=HTMLResponse, tags=["Pages"])
async def about(request: Request):
    """Page À propos"""
    return templates.TemplateResponse("about.html", {
        "request": request, 
        "current": "about"
    })

@app.get("/service", response_class=HTMLResponse, tags=["Pages"])
async def service(request: Request):
    """Page Services"""
    return templates.TemplateResponse("service.html", {
        "request": request, 
        "current": "service"
    })

@app.get("/blog", response_class=HTMLResponse, tags=["Pages"])
async def blog(request: Request):
    """Page Blog"""
    return templates.TemplateResponse("blog.html", {
        "request": request, 
        "current": "blog"
    })

@app.get("/detail", response_class=HTMLResponse, tags=["Pages"])
async def detail(request: Request):
    """Page Détails"""
    return templates.TemplateResponse("detail.html", {
        "request": request, 
        "current": "detail"
    })

@app.get("/contact", response_class=HTMLResponse, tags=["Pages"])
async def contact(request: Request):
    """Page Contact"""
    return templates.TemplateResponse("contact.html", {
        "request": request, 
        "current": "contact"
    })

# ==========================================
# SECTION DÉCOUVREZ
# ==========================================
@app.get("/decouvrez/valeurs", response_class=HTMLResponse, tags=["Découvrez"])
async def valeurs(request: Request):
    """Page Nos Valeurs"""
    return templates.TemplateResponse("valeurs.html", {
        "request": request, 
        "current": "valeurs"
    })

@app.get("/decouvrez/clients", response_class=HTMLResponse, tags=["Découvrez"])
async def clients(request: Request):
    """Page Nos Clients"""
    return templates.TemplateResponse("clients.html", {
        "request": request, 
        "current": "clients"
    })

@app.get("/decouvrez/strategie", response_class=HTMLResponse, tags=["Découvrez"])
async def strategie(request: Request):
    """Page Notre Stratégie"""
    return templates.TemplateResponse("strategie.html", {
        "request": request, 
        "current": "strategie"
    })

# ==========================================
# SECTION CARRIÈRES
# ==========================================
@app.get("/carrieres/rechercherpostuler", response_class=HTMLResponse, tags=["Carrières"])
async def rechercher_postuler(request: Request):
    """Page Rechercher et Postuler"""
    return templates.TemplateResponse("rechercherpostuler.html", {
        "request": request, 
        "current": "rechercherpostuler", 
        "posts": posts
    })

@app.get("/carrieres/job/{id}", response_class=HTMLResponse, tags=["Carrières"])
async def job(id: str, request: Request):
    """Page Détails d'une Offre d'Emploi"""
    post = next((p for p in posts if p["id"] == id), None)
    
    if post:
        return templates.TemplateResponse("job.html", {
            "request": request, 
            "post": post
        })
    else:
        return templates.TemplateResponse("404.html", {
            "request": request
        }, status_code=404)

@app.get("/carrieres/jeunediplomes", response_class=HTMLResponse, tags=["Carrières"])
async def jeune_diplomes(request: Request):
    """Page Jeunes Diplômés"""
    return templates.TemplateResponse("jeunediplomes.html", {
        "request": request, 
        "current": "jeunediplomes"
    })

@app.get("/carrieres/etudiants", response_class=HTMLResponse, tags=["Carrières"])
async def etudiants(request: Request):
    """Page Étudiants"""
    return templates.TemplateResponse("etudiants.html", {
        "request": request, 
        "current": "etudiants"
    })

@app.get("/carrieres/formation", response_class=HTMLResponse, tags=["Carrières"])
async def formation(request: Request):
    """Page Formation"""
    return templates.TemplateResponse("formation.html", {
        "request": request, 
        "current": "formation"
    })

@app.get("/carrieres/environnementdetravail", response_class=HTMLResponse, tags=["Carrières"])
async def environnement_travail(request: Request):
    """Page Environnement de Travail"""
    return templates.TemplateResponse("environnementdetravail.html", {
        "request": request, 
        "current": "environnementdetravail"
    })

# ==========================================
# ERROR HANDLERS
# ==========================================
@app.exception_handler(404)
async def not_found_handler(request: Request, exc: HTTPException):
    """Handler pour les pages non trouvées"""
    if request.url.path.startswith("/api"):
        return JSONResponse(
            status_code=404,
            content={
                "error": "Not Found",
                "message": f"La route {request.url.path} n'existe pas",
                "timestamp": datetime.now().isoformat()
            }
        )
    return templates.TemplateResponse("404.html", {
        "request": request
    }, status_code=404)

@app.exception_handler(500)
async def internal_error_handler(request: Request, exc: Exception):
    """Handler pour les erreurs serveur"""
    logger.error(f"Erreur serveur: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "message": "Une erreur s'est produite. Veuillez réessayer plus tard.",
            "timestamp": datetime.now().isoformat()
        }
    )

# ==========================================
# STARTUP & SHUTDOWN EVENTS
# ==========================================
@app.on_event("startup")
async def startup_event():
    """Événement au démarrage de l'application"""
    logger.info("=" * 60)
    logger.info("🚀 Démarrage de Mahrasoft.com")
    logger.info("=" * 60)
    logger.info(f"📂 Répertoire de base: {BASE_DIR}")
    logger.info(f"📁 Dossier static: {STATIC_DIR}")
    logger.info(f"📁 Dossier templates: {TEMPLATES_DIR}")
    logger.info(f"📄 Fichier db.json: {DB_FILE}")
    logger.info(f"📊 Offres d'emploi chargées: {len(posts)}")
    logger.info(f"🌐 Version: 1.0.0")
    logger.info("=" * 60)

@app.on_event("shutdown")
async def shutdown_event():
    """Événement à l'arrêt de l'application"""
    logger.info("🛑 Arrêt de Mahrasoft.com")
    logger.info("🛑 Arrêt de Mahrasoft.com")