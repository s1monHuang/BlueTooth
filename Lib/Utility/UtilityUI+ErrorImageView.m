//
//  UtilityUI+ErrorImageView.m
//
//

#import "UtilityUI+ErrorImageView.h"
#import <objc/runtime.h>

static char viewTapHandlerKey;
static char baseViewBGViewKey;


@implementation UtilityUI (ErrorImageView)

+ (void)showErrorImageView:(UIView *)baseView
                      text:(NSString *)text
{
    [[self class] showErrorImageView:baseView image:nil text:text];
}


+ (void)showErrorImageView:(UIView *)baseView
                     image:(UIImage *)image
{
    [[self class] showErrorImageView:baseView image:image text:nil];
}


+ (void)showErrorImageView:(UIView *)baseView
                     image:(UIImage *)image
                      text:(NSString *)text
{
    [[self class] showErrorImageView:baseView image:image text:text viewTapHandler:nil];
}

+ (void)showErrorImageView:(UIView *)baseView
                     image:(UIImage *)image
                      text:(NSString *)text
            viewTapHandler:(ViewTapHandler)viewTapHandler

{
    [[self class] showErrorImageView:baseView image:image text:text textFont:nil textColor:nil backgroundColor:nil edgeInset:UIEdgeInsetsZero showedAtTop:NO viewTapHandler:viewTapHandler];
}

+ (void)showErrorImageView:(UIView *)baseView
                     image:(UIImage *)image
                      text:(NSString *)text
               showedAtTop:(BOOL)showedAtTop
            viewTapHandler:(ViewTapHandler)viewTapHandler

{
    [[self class] showErrorImageView:baseView image:image text:text textFont:nil textColor:nil backgroundColor:nil edgeInset:UIEdgeInsetsZero showedAtTop:showedAtTop viewTapHandler:viewTapHandler];
}

+ (void)showErrorImageView:(UIView *)baseView
                     image:(UIImage *)image
                      text:(NSString *)text
                  textFont:(UIFont *)textFont
                 textColor:(UIColor *)textColor
           backgroundColor:(UIColor *)backgroudColor
                 edgeInset:(UIEdgeInsets)edgeInset
               showedAtTop:(BOOL)showedAtTop
            viewTapHandler:(ViewTapHandler)viewTapHandler

{
    if (!baseView) return;
    if (!image && !text) return;
    
    [[self class] hideErrorImageView:baseView];
    
    CGRect baseViewBounds = baseView.bounds;
    CGRect bgFrame = CGRectMake(baseViewBounds.origin.x + edgeInset.left,
                                baseViewBounds.origin.y + edgeInset.top,
                                baseViewBounds.size.width - edgeInset.left - edgeInset.right,
                                baseViewBounds.size.height - edgeInset.top - edgeInset.bottom);
    
    UIView *baseBackgroundView = [[UIView alloc] initWithFrame:bgFrame];
    baseBackgroundView.backgroundColor = backgroudColor ?: baseView.backgroundColor;
    [baseView addSubview:baseBackgroundView];
    [baseView bringSubviewToFront:baseBackgroundView];
    
    CGFloat padding = 20.0f;
    CGFloat centerY =  baseBackgroundView.bounds.size.height / 2.0f;
    CGFloat centerX =  baseBackgroundView.bounds.size.width / 2.0f;
    CGFloat maxHeight = centerY - padding * 2;
    CGFloat maxWidth = baseBackgroundView.bounds.size.width - padding * 4;
    
    UIImageView *imageView;
    if (image) {
//        CGSize imageSize = [UtilityFunc aspectShrinkSize:image.size maxWidth:maxWidth maxHeight:maxHeight];
        CGSize imageSize = CGSizeZero;
        CGFloat imageY = StringNotEmpty(text) ? (centerY - imageSize.height) : (centerY - imageSize.height / 2.0f);
        if (showedAtTop) imageY = padding * 3;
        CGRect imageFrame;
        imageFrame.size.width = imageSize.width ;
        imageFrame.size.height = imageSize.height;
        imageFrame.origin.x = centerX - imageSize.width / 2;
        imageFrame.origin.y = imageY;
        
        imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        imageView.image = image;
        [baseBackgroundView addSubview:imageView];
    }

    
    if (text && text.length > 0) {
        UIFont *font =  textFont ?: [UIFont systemFontOfSize:16.0f];
        CGSize textSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(maxWidth, maxHeight)];
        
        CGRect textFrame;
        textFrame.size.width = maxWidth ;
        textFrame.size.height = textSize.height <= maxHeight ? textSize.height : maxHeight ;
        textFrame.origin.x = padding * 2;
        textFrame.origin.y = imageView ? CGRectGetMaxY(imageView.frame) + padding : (centerY + padding) ;
        
        UILabel *label = [[UILabel alloc] initWithFrame:textFrame];
        label.textColor = textColor ?: RGB(138, 159, 166);
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.font = font;
        label.numberOfLines = 0;
        label.text = text;
        [baseBackgroundView addSubview:label];
    }
    
    
    objc_setAssociatedObject(baseView, &baseViewBGViewKey, baseBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (viewTapHandler) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlerTapClick:)];
        [baseBackgroundView addGestureRecognizer:tap];
        
        objc_setAssociatedObject(baseView, &viewTapHandlerKey, viewTapHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

+ (void)hideErrorImageView:(UIView *)baseView {
    if (!baseView) return;
    
    id object = objc_getAssociatedObject(baseView, &baseViewBGViewKey);
    if (object) {
        UIView *view = object;
        [view removeFromSuperview];
        objc_setAssociatedObject(baseView, &baseViewBGViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    id objectBlock = objc_getAssociatedObject(baseView, &viewTapHandlerKey);
    if (objectBlock) {
        objc_setAssociatedObject(baseView, &viewTapHandlerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

+ (void)handlerTapClick:(UITapGestureRecognizer *)tap
{
    UIView *baseView = tap.view.superview;
    if (!baseView) return;
    
    id object = objc_getAssociatedObject(baseView, &viewTapHandlerKey);
    if (object) {
        ViewTapHandler viewTapHandler = object;
        [[self class] hideErrorImageView:baseView];
        viewTapHandler(nil);
    }
}

@end
