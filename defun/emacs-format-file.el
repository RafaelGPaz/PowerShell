(defun emacs-format-function ()
  "Format the whole buffer."
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max))
  (set-buffer-modified-p t)
  (save-buffer)
  )