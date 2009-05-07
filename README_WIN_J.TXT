ets - an Easy Template System (Windows�����C���X�g�[���菇��)

2009/05/08

���Ƃ肠���������ɂ�
  sample.ets �t�@�C���� ets.bat �Ƀh���b�O�A���h�h���b�v���Ă݂ĉ������B
  sample-out.txt ����������܂��B

���͂��߂�
  Easy Template System (ets) �̓V�F���X�N���v�g���̕ϐ��u�����\��
  �f�X�N�g�b�v���[�U�����̔��ɃV���v���ȃe���v���[�g�G���W���ł��B

  ��̓��� �ϐ��ݒ�t�@�C��(*.ets) �� �e���v���[�g�t�@�C��(*.template)
  ���������ďo�̓t�@�C���𐶐����܂��B

   �ϐ��ݒ�t�@�C��(sample.ets)
       | __TEMPLATE_FILE__ = "�e���v���[�g�t�@�C����"
       | __OUTPUT_FILE__ = "�o�̓t�@�C����"
       | WHO = brown fox
       | WHOM =    " the lazy dog"
       | HEREDOC =<< EOL
       | This is
       | multi line
       | definition using heredoc syntax.
       | EOL

   �e���v���[�g(sample.template):
       | Quick ${WHO} jumped over${WHOM}.
       | Heredoc sample: ${HEREDOC}

   �o�͗�:
       | Quick brown fox jumped over the lazy dog.
       | Heredoc sample: This is
       | multi line
       | definition using heredoc syntax.


���g�p���@
  �R�}���h���C���ł̎g�p���@�� README.TXT(�p��) ���Q�Ƃ��ĉ������B
  �����ł̓C���X�g�[���菇�ɏ]���ăZ�b�g�A�b�v������A�_�u���N���b�N
  �܂��̓h���b�O�A���h�h���b�v�Ŏg�p������@��������܂��B

  <1> �ϐ��ݒ�t�@�C���� XXXX.ets �Ƃ������O�ō쐬���܂��B���̂Ƃ��A
      �K�� __TEMPLATE_FILE__ �� __OUTPUT_FILE__ �ϐ���ݒ肵�Ă����܂��B

  <2> XXXX.ets �� ets.bat �Ƀh���b�O�A���h�h���b�v���܂��B
      (�C���X�g�[���菇 A �̏ꍇ)

      �܂��� XXXX.ets ���_�u���N���b�N���܂��B
      (�C���X�g�[���菇 B �̏ꍇ)

�����{��Ɋւ��钍��
  �����R�[�h�̎����ϊ��ɂ͑Ή����Ă��܂���̂�
  �ϐ��ݒ�t�@�C��(*.ets) �� �e���v���[�g�t�@�C���̕����R�[�h
  (���s�R�[�h��)����v������悤�ɂ��ĉ������B

���C���X�g�[���菇(����)
  Python 2.5 for Windows �����L����_�E�����[�h���ăC���X�g�[�����܂�

      http://www.python.org/ftp/python/2.5.4/python-2.5.4.msi

  (Python3000 �͖��T�|�[�g�ł�)


���C���X�g�[���菇 A: ets.bat ���g�p

  ets.py �� ets.bat ���D���ȏꏊ�ɃR�s�[���܂��B
  (��̃t�@�C���𓯂��ꏊ�ɒu���ĉ�����)
  �g�p����ۂ͕ϐ��ݒ�t�@�C���� ets.bat �Ƀh���b�v���܂��B


���C���X�g�[���菇 A: �t�@�C���֘A�t��

  <1> ets.py ���D���ȏꏊ�փR�s�[���܂��B�����ł͉���
      "C:\Programs\ets\ets.py" �ɃR�s�[�����Ƃ��܂��B

  <2> �t�@�C���̊֘A�t���ňȉ��̃R�}���h���C�����g���q ets �Ɏw�肵�܂��B

        "C:\Python25\pythonw.exe" "C:\Programs\ets\ets.py" --gui
        --outfile-in-config --template-in-config "%1"
        (���ۂ͈�s�œ���)

        ���R���g���[���p�l�����t�H���_�I�v�V�������t�@�C���̎��
          ����u�V�K�v�� ETS ��ǉ����A�A�N�V�������쐬���܂��B
        ���㏑����������ɂ� --overwrite ��ǉ����ĉ������B
        ��Pythonw.exe�̏ꏊ�͎��ۂ̃C���X�g�[���ꏊ�ɍ����ĉ������B

      sample.ets ���_�u���N���b�N���邾���� sample-out.txt ��
      ���������悤�ɂȂ�ΐ����ł��B

  <3> [�C��] �t�@�C���̊֘A�t���ŁA�u�ҏW�v�A�N�V�����Ȃǂ�
      �ǉ����Ă����ƕ֗��ł��傤�B