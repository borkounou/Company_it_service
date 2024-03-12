from fastapi import FastAPI, status, HTTPException, Request
from fastapi.staticfiles import StaticFiles 
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse 



app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

@app.get("/", response_class=HTMLResponse)
async def index(request: Request):
    return templates.TemplateResponse("index.html", {"request":request})

@app.get("/info1", response_class=HTMLResponse)
async def about(request: Request):
    return templates.TemplateResponse("about.html", {"request":request})