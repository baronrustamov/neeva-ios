// Original code by Andrew Jones.
// https://dev.to/ajones_codes/how-i-made-an-ios-15-safari-extension-to-get-rid-of-annoying-reddit-open-in-app-pop-ups-559p.
const redditViewer = () => {
    const looksBetterBanner = document.querySelector(".XPromoPill");
    if (looksBetterBanner) looksBetterBanner.parentNode.removeChild(looksBetterBanner);
    
    const seeCommunityIn = document.querySelector(".XPromoPopup");
    if (seeCommunityIn) seeCommunityIn.parentNode.removeChild(seeCommunityIn);
        
    const promoInFeed = document.querySelector(".XPromoInFeed");
    if (promoInFeed) promoInFeed.parentNode.removeChild(promoInFeed);
            
    const promoInFooter = document.querySelector(".xPromoAppStoreFooter");
    if (promoInFooter) promoInFooter.parentNode.removeChild(promoInFooter);
        
    const promoBlockingModal = document.querySelector(".XPromoBlockingModal");
    if (promoBlockingModal) promoBlockingModal.parentNode.removeChild(promoBlockingModal);
        
    const seeThisPostIn = document.querySelector("shreddit-experience-tree");
    if (seeThisPostIn) seeThisPostIn.parentNode.removeChild(seeThisPostIn);

    // Prevents a blur that would sometimes occur on thread pages.
    const viewBlur = document.querySelector(".m-blurred");
    if (viewBlur) viewBlur.style.filter = "none";
        
    const body = document.querySelector("body");
    body.classList.remove("scroll-disabled");
    body.classList.remove("scroll-is-blocked");
}

if (window.location.host == "www.reddit.com") {
    const interval = setInterval(redditViewer, 250);
}
