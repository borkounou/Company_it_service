from fastapi import FastAPI, status, HTTPException, Request
from fastapi.staticfiles import StaticFiles 
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse 
import json
from datetime import datetime
from fastapi.middleware.cors import CORSMiddleware
import logging
import os
# def https_url_for(request:Request, name:str, **path_params:any)->str:
#     http_url = request.url_for(name, **path_params)
#     https_url =str(http_url).replace("http", "https", 1)
#     return request.url_for(name, **path_params)



with open("db.json") as file:
    posts = json.load(file)
posts = posts["posts"]


def https_url_for(request:Request, name:str, **path_params:any)->str:
    http_url = request.url_for(name, **path_params)
    https_url =str(http_url).replace("http", "https", 1)
    return https_url#request.url_for(name, **path_params)


logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Créer l'application FastAPI
app = FastAPI(
    title="Mahrasoft.com API",
    description="API pour le site web Mahrasoft Innovations",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

app.mount("/static", StaticFiles(directory="./static"), name="static")
templates = Jinja2Templates(directory="templates")

templates.env.globals["https_url_for"] = https_url_for

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = datetime.now()
    response = await call_next(request)
    process_time = (datetime.now() - start_time).total_seconds()
    
    logger.info(
        f"{request.method} {request.url.path} "
        f"- Status: {response.status_code} "
        f"- Time: {process_time:.3f}s"
    )
    
    return response

@app.get("/", response_class=HTMLResponse)
async def index(request: Request):
    return templates.TemplateResponse("index.html", {"request":request, "current":"index"})


@app.get("/about", response_class=HTMLResponse)
async def about(request: Request):
    return templates.TemplateResponse("about.html", {"request":request, "current":"about"})


@app.get("/service", response_class=HTMLResponse)
async def service(request: Request):
    return templates.TemplateResponse("service.html", {"request":request, "current":"service"})


@app.get("/blog", response_class=HTMLResponse)
async def blog(request: Request):
    return templates.TemplateResponse("blog.html", {"request":request, "current":"blog"})


@app.get("/detail", response_class=HTMLResponse)
async def detail(request: Request):
    return templates.TemplateResponse("detail.html", {"request":request, "current":"detail"})

@app.get("/contact", response_class=HTMLResponse)
async def contact(request: Request):
    return templates.TemplateResponse("contact.html", {"request":request, "current":"contact"})

@app.get("/decouvrez/valeurs", response_class=HTMLResponse)
async def price(request: Request):
    return templates.TemplateResponse("valeurs.html", {"request":request, "current":"valeurs"})

@app.get("/decouvrez/clients", response_class=HTMLResponse)
async def feature(request: Request):
    return templates.TemplateResponse("clients.html", {"request":request, "current":"clients"})

@app.get("/decouvrez/strategie", response_class=HTMLResponse)
async def team(request: Request):
    return templates.TemplateResponse("strategie.html", {"request":request, "current":"strategie"})

@app.get("/carrieres/rechercherpostuler", response_class=HTMLResponse)
async def testimonial(request: Request):
   
    return templates.TemplateResponse("rechercherpostuler.html", {"request":request, "current":"rechercherpostuler", "posts":posts})

@app.get("/carrieres/job/{id}",response_class=HTMLResponse)
async def job(id:str, request:Request):
    post = next((p for p in posts if p["id"]==id),None)

    if post: 
        return templates.TemplateResponse("job.html", {"request":request, "post":post})
    
    else:
        return templates.TemplateResponse("404.html",{"request":request})

@app.get("/carrieres/jeunediplomes", response_class=HTMLResponse)
async def quote(request: Request):
    return templates.TemplateResponse("jeunediplomes.html", {"request":request, "current":"jeunediplomes"})

@app.get("/carrieres/etudiants", response_class=HTMLResponse)
async def quote(request: Request):
    return templates.TemplateResponse("etudiants.html", {"request":request, "current":"etudiants"})

@app.get("/carrieres/formation", response_class=HTMLResponse)
async def quote(request: Request):
    return templates.TemplateResponse("formation.html", {"request":request, "current":"formation"})

@app.get("/carrieres/environnementdetravail", response_class=HTMLResponse)
async def quote(request: Request):
    return templates.TemplateResponse("environnementdetravail.html", {"request":request, "current":"environnementdetravail"})
