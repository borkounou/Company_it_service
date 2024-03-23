window.sr = ScrollReveal();
sr.reveal('.navbar', {
    duration:2500,
    origin:'bottom'
});

sr.reveal('.showcase-left',{
    duration:2500,
    origin:'top',
    distance:'400px'
});

sr.reveal('.showcase-right',{
    duration:2500,
    origin:'right',
    distance:'400px'
});


sr.reveal('.showcase-btn',{
    duration:2500,
    delay:2000,
    origin:'bottom',
  
});



sr.reveal('#testimonial div',{
    duration:2500,
    origin:'bottom',
  
});



sr.reveal('.info-left',{
    duration:2500,
    origin:'left',
    distance:'400px',
    viewFactor:0.3
  
});


sr.reveal('.info-right',{
    duration:2500,
    origin:'right',
    distance:'400px',
    viewFactor:0.3
  
});




$(function(){
    $('a[href*="#"]:not([href="#"])').click(
        function(){
            if(location.pathname.replace(/^\//,'')==this.pathname.replace(/^\//,'') && location.pathname == this.hostname){
                var target = $(this.hash);
                target = target.length ? target: $('[name='+this.hash.slice(1)+']');
                if(target.length){
                    $('html', 'body').animate({
                        scrollTop: target.offset().top
                    },1000);
                    return false;
                }
            }
        }
    );
});