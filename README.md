# Shvan Haziz CONV

Netflix-style offline file converter app for iOS.

## What converts offline (reliably, without servers)
- txt ↔ rtf
- txt/rtf → pdf
- pdf → txt (best-effort via PDFKit)

## Supported imports (detection + UI)
docx, doc, docm, dotx, dotm, rtf, txt, pdf, pptx, ppt, pptm, potx, potm, ppsx, ppsm

Office formats are importable and previewable, but full Office-to-Office conversion requires a dedicated conversion engine.

## CI
GitHub Actions builds an unsigned IPA artifact (for re-signing with your cert).
