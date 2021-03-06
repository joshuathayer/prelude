(prelude-ensure-module-deps
 '(ack-and-a-half
   auto-complete
   diminish
;;   ergoemacs-mode
   framemove
   idle-highlight-mode
   ido-vertical-mode
   multiple-cursors
   nrepl
   rainbow-delimiters
   windmove
   yasnippet))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions and Macros
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; http://milkbox.net/note/single-file-master-emacs-configuration/
(defmacro after (mode &rest body)
  "`eval-after-load' MODE evaluate BODY."
  (declare (indent defun))
  `(eval-after-load ,mode
     '(progn ,@body)))

(defun z:mac-p ()
  "Truthy if the host OS is a Mac."
  (string-match "apple-darwin" system-configuration))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq-default truncate-lines t)

(load-theme 'solarized-dark)
(when window-system
  (let ((default-font (if (z:mac-p)
                        ;;  "-apple-Anonymous_Pro_Minus-medium-normal-normal-*-12-*-*-*-m-0-iso10646-1"
                         "Source Code Pro 12"
                        ;;"Inconsolata-13"
                        "Monospace 10")))
    (set-face-font 'default default-font))
  (scroll-bar-mode -1))

(let ((cursor-color "#d33682"))
  (set-cursor-color cursor-color)
  ;; (add-to-list 'default-frame-alist `(cursor-color . ,cursor-color))
  )

;; http://xahlee.blogspot.com/2009/08/how-to-use-and-setup-emacss-whitespace.html
(setq whitespace-trailing-regexp
      "^.*[^\r\n\t \xA0\x8A0\x920\xE20\xF20]+\\([\t \xA0\x8A0\x920\xE20\xF20]+\\)$")
(setq whitespace-style '(face tabs trailing empty))
(setq whitespace-action '(auto-cleanup warn-if-read-only))
(global-whitespace-mode 1)


(after "rainbow-delimiters-autoloads"
  (defun zane-turn-on-rainbow-delimiters-mode ()
    (rainbow-delimiters-mode 1))

  (setq-default frame-background-mode 'dark)
  (let ((hooks '(emacs-lisp-mode-hook
                 clojure-mode-hook
                 javascript-mode-hook
                 lisp-mode-hook
                 python-mode-hook)))
    (dolist (hook hooks)
      (add-hook hook 'zane-turn-on-rainbow-delimiters-mode))))

(after 'paren
  (set-face-background 'show-paren-match nil)
  (set-face-foreground 'show-paren-match nil)
  (set-face-inverse-video-p 'show-paren-match nil)
  (set-face-attribute 'show-paren-match nil :underline (face-background 'cursor)))

(after "ido-vertical-mode-autoloads" (ido-vertical-mode +1))

(after "diminish-autoloads"
  (defmacro rename-modeline (package-name mode new-name)
    `(eval-after-load ,package-name
       '(defadvice ,mode (after rename-modeline activate)
          (setq mode-name ,new-name))))

  ;; http://whattheemacsd.com//appearance.el-01.html
  (rename-modeline 'lisp-mode emacs-lisp-mode "EL")
  (rename-modeline 'js js-mode "JS")
  (rename-modeline 'lisp-mode lisp-interaction-mode "LI")

  (after 'eldoc           (diminish 'eldoc-mode             " ed"))
  (after 'elisp-slime-nav (diminish 'elisp-slime-nav-mode   " sn"))
  (after 'paredit         (diminish 'paredit-mode           " pe"))
  (after 'simple          (diminish 'auto-fill-function     " af"))

  (after 'auto-complete       (diminish 'auto-complete-mode))

  ;; (defun diminish-ergoemacs-mode ()
  ;;   (diminish 'ergoemacs-mode))
  ;; (add-hook 'ergoemacs-mode-hook 'diminish-ergoemacs-mode)

  (after 'undo-tree           (diminish 'undo-tree-mode))
  (after 'volatile-highlights (diminish 'volatile-highlights-mode))
  (after 'whitespace          (diminish 'global-whitespace-mode))
  (after 'yasnippet           (diminish 'yas-minor-mode))

  (after 'flycheck
    (setq flycheck-mode-line-lighter " Κ")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Coding
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(after 'js
  (setq js-indent-level 2)
  (define-key js-mode-map (kbd ",") 'self-insert-command)
  (define-key js-mode-map (kbd "RET") 'reindent-then-newline-and-indent)
  (font-lock-add-keywords 'js-mode `(("\\(function *\\)("
                                      (0 (progn (compose-region (match-beginning 1)
                                                                (match-end 1)
                                                                "ƒ")
                                                nil))))))

(after "flycheck-autoloads"
  ;; Use flycheck for all modes that aren't emacs-lisp-mode
  (defun zane-maybe-turn-on-flycheck-mode ()
    (when (not (equal 'emacs-lisp-mode major-mode))
      (flycheck-mode)))
  (add-hook 'find-file-hook 'zane-maybe-turn-on-flycheck-mode)
  
  (after 'flycheck
    (set-face-attribute 'flycheck-error nil :underline "red")
    (set-face-attribute 'flycheck-warning nil :underline "yellow")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Keybindings and Ergoemacs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Tab key
;; http://stackoverflow.com/questions/1792326/how-do-i-bind-a-command-to-c-i-without-changing-tab
(keyboard-translate ?\C-i ?\H-i)

;; (require 'ergoemacs-mode)

;; (after 'ergoemacs-mode
;;   (setenv "ERGOEMACS_KEYBOARD_LAYOUT" "us")

;;   (ergoemacs-deftheme zane
;;     "Zane Shelby theme -- ALL key except <apps> and <menu> keys."
;;     nil
;;     (ergoemacs-replace-key 'ergoemacs-smex-if-exists "M-a" "M-a")
;;     (ergoemacs-replace-key 'ergoemacs-cut-line-or-region "M-x" "✂ region")
;;     (ergoemacs-minor-key 'ido-minibuffer-setup-hook '(forward-char ido-next-match-dir minor-mode-overriding-map-alist))
;;     (ergoemacs-minor-key 'ido-minibuffer-setup-hook '(backward-char ido-prev-match-dir minor-mode-overriding-map-alist))
;;     (ergoemacs-minor-key 'ido-minibuffer-setup-hook '(previous-line ido-prev-match minor-mode-overriding-map-alist))
;;     (ergoemacs-minor-key 'ido-minibuffer-setup-hook '(next-line ido-next-match minor-mode-overriding-map-alist))
;;     ;; "<M-backspace>" backward-kill-word
;;     (setq ergoemacs-variable-layout-tmp
;;           (remove-if (lambda (x) (or (string-match "<apps>" (car x))
;; 				     (string-match "<menu>" (car x))
;; 				     (string-match "<M-backspace>" (car x))))
;;                      ergoemacs-variable-layout)))
;;   (setq ergoemacs-theme "zane")
;;   (ergoemacs-mode 1)

;;   (after 'windmove
;;     (define-key lisp-interaction-mode-map (kbd "C-j") nil)
;;     (global-set-key (kbd "H-i") 'windmove-up)
;;     (global-set-key (kbd "C-l") 'windmove-right)
;;     (global-set-key (kbd "C-j") 'windmove-left)
;;     (global-set-key (kbd "C-k") 'windmove-down))

;;   (after "multiple-cursors-autoloads"
;;     (setq mc/list-file (expand-file-name ".mc-lists.el" prelude-savefile-dir))
    
;;     (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
;;     (global-set-key (kbd "C->") 'mc/mark-next-like-this)
;;     (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
;;     (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this))

;;   (after "expand-region-autoloads"
;;     (global-set-key (kbd "M->") 'er/expand-region)
;;     (global-set-key (kbd "M-<") 'er/contract-region))
  
;;   (after 'dired
;;     (define-key dired-mode-map (kbd "C-o") nil))
  
;;   (global-set-key [remap move-beginning-of-line]
;;                   'prelude-move-beginning-of-line)

;;   (after "smartparens-autoloads"
;;     (global-set-key [remap backward-up-list]
;;                     'sp-backward-up-sexp))
  
;;   (global-set-key (kbd "M-x") 'ergoemacs-cut-line-or-region)

;;   (after 'nrepl
;;     (define-key nrepl-mode-map (kbd "C-j") nil))

;;   (after "smex-autoloads"
;;     (global-set-key (kbd "M-a") 'smex)
;;     (global-set-key (kbd "M-A") 'smex-major-mode-commands)
;;     (global-set-key (kbd "C-c C-c M-a") 'execute-extended-command))
  
;;   (cua-mode -1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; auto-complete
(require 'auto-complete)

(setq ac-comphist-file (expand-file-name "ac-comphist.dat" prelude-savefile-dir))
(setq ac-auto-start nil)
(setq ac-show-menu-immediately-on-auto-complete t)
(setq ac-dwim t)
(setq ac-delay 0)
(setq ac-expand-on-auto-complete t)
(ac-set-trigger-key "TAB")
(setq ac-use-menu-map t)
(setq ac-use-fuzzy nil)
(after 'fuzzy (setq ac-use-fuzzy t))
(define-key ac-menu-map (kbd "M-i") 'ac-previous)
(define-key ac-menu-map (kbd "M-k") 'ac-next)
(global-auto-complete-mode t)
;; /auto-complete

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Visual Bell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defcustom echo-area-bell-string "*DING* " ;"♪"
  "Message displayed in mode-line by `echo-area-bell' function."
  :group 'user)
(defcustom echo-area-bell-delay 0.1
  "Number of seconds `echo-area-bell' displays its message."
  :group 'user)
;; internal variables
(defvar echo-area-bell-cached-string nil)
(defvar echo-area-bell-propertized-string nil)
(defun echo-area-bell ()
  "Briefly display a highlighted message in the echo-area.
    The string displayed is the value of `echo-area-bell-string',
    with a red background; the background highlighting extends to the
    right margin.  The string is displayed for `echo-area-bell-delay'
    seconds.
    This function is intended to be used as a value of `ring-bell-function'."
  (unless (equal echo-area-bell-string echo-area-bell-cached-string)
    (setq echo-area-bell-propertized-string
          (propertize
           (concat
            (propertize
             "x"
             'display
             `(space :align-to (- right ,(+ 2 (length echo-area-bell-string)))))
            echo-area-bell-string)
           'face '(:background "white")))
    (setq echo-area-bell-cached-string echo-area-bell-string))
  (message echo-area-bell-propertized-string)
  (sit-for echo-area-bell-delay)
  (message ""))
(setq ring-bell-function 'echo-area-bell)
