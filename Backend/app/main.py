from fastapi import FastAPI, status, HTTPException, Request
from fastapi.staticfiles import StaticFiles 
from fastapi.templating import Jinja2Templates
from fastapi.responses import HTMLResponse 



# def https_url_for(request:Request, name:str, **path_params:any)->str:
#     http_url = request.url_for(name, **path_params)
#     https_url =str(http_url).replace("http", "https", 1)
#     return request.url_for(name, **path_params)

def https_url_for(request:Request, name:str, **path_params:any)->str:
    http_url = request.url_for(name, **path_params)
    https_url =str(http_url).replace("http", "https", 1)
    return https_url#request.url_for(name, **path_params)


app = FastAPI()
app.mount("/static", StaticFiles(directory="./static"), name="static")
templates = Jinja2Templates(directory="templates")

templates.env.globals["https_url_for"] = https_url_for

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

@app.get("/pages/price", response_class=HTMLResponse)
async def price(request: Request):
    return templates.TemplateResponse("price.html", {"request":request, "current":"price"})

@app.get("/pages/feature", response_class=HTMLResponse)
async def feature(request: Request):
    return templates.TemplateResponse("feature.html", {"request":request, "current":"feature"})

@app.get("/pages/team", response_class=HTMLResponse)
async def team(request: Request):
    return templates.TemplateResponse("team.html", {"request":request, "current":"team"})

@app.get("/pages/testimonial", response_class=HTMLResponse)
async def testimonial(request: Request):
    return templates.TemplateResponse("testimonial.html", {"request":request, "current":"testimonial"})

@app.get("/pages/quote", response_class=HTMLResponse)
async def quote(request: Request):
    return templates.TemplateResponse("quote.html", {"request":request, "current":"quote"})