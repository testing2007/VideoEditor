/*
 * audio_reader_wav.cpp
 *
 *  Created on: 2014ƒÍ8‘¬28»’
 *      Author: …–≤©≤≈
 */

#include "audio_reader_wav.h"
#include "audio_utils.h"

#include <string.h>
#include <stdio.h>

AudioReaderWav::AudioReaderWav() :
        channel_count_(0), bit_rate_(-1), channel_layout_(kMono),
        sample_format_(kSampleFmtS16), sample_rate_(-1), buffer_size_(0),
        wav_file_(NULL), frame_size_(0) {
    //wav_header_ = {0};
}

AudioReaderWav::~AudioReaderWav() {
    F_AUDIO_LOG_VERBOSE("begin");
	if(wav_file_ != NULL) {
		fclose(wav_file_);
		wav_file_ = NULL;
	}

    F_AUDIO_LOG_VERBOSE("end");
}

int AudioReaderWav::InitInputFile(const char* file_name) {
    F_AUDIO_LOG_VERBOSE("begin");
    int error;
    error = OpenInputAudioFile(file_name);
    if(error)
    	return error;

    // Ω‚ŒˆwavŒƒº˛Õ∑
    char ch[5];
      int itmp;
      short stmp;
      int bpersec;
      short balign;
      int skip_bytes;
      int i;

      ch[4]=0;
      fread(ch, 1, 4, wav_file_);
      if (strcmp(ch, "RIFF")!=0)
      {
         fclose(wav_file_);
         wav_file_ = NULL;
         F_AUDIO_LOG_ERROR("file %s is not a wave file", file_name);
         return kNotFindAudioStream;
      }
      memcpy(wav_header_.riff_fileid, ch, 4);

      fread(&itmp, 4, 1, wav_file_);
      wav_header_.riff_file_length = le_int(itmp);

      fread(ch, 1, 4, wav_file_);
      if (strcmp(ch, "WAVE")!=0)
      {
    	  fclose(wav_file_);
		   wav_file_ = NULL;
		   F_AUDIO_LOG_ERROR("file %s is not a wave file", file_name);
         return kNotFindAudioStream;
      }
      memcpy(wav_header_.waveid, ch, 4);

      fread(ch, 1, 4, wav_file_);
      while (strcmp(ch, "fmt ")!=0)
      {
         fread(&itmp, 4, 1, wav_file_);
         itmp = le_int(itmp);
         /*fprintf (stderr, "skip=%d\n", itmp);*/
         /*strange way of seeking, but it works even for pipes*/
         for (i=0;i<itmp;i++)
            fgetc(wav_file_);
         /*fseek(file, itmp, SEEK_CUR);*/
         fread(ch, 1, 4, wav_file_);
         if (feof(wav_file_))
         {
        	 fclose(wav_file_);
			 wav_file_ = NULL;
			 F_AUDIO_LOG_ERROR("Corrupted WAVE file: no \"fmt \"");
			 return kNotFindAudioStream;
         }
      }
      memcpy(wav_header_.waveid, ch, 4);

      fread(&itmp, 4, 1, wav_file_);
      itmp = le_int(itmp);
      skip_bytes=itmp-16;
      wav_header_.fmt_chk_length = itmp;

      fread(&stmp, 2, 1, wav_file_);
      stmp = le_short(stmp);
      if (stmp!=1)
      {
         fclose(wav_file_);
		 wav_file_ = NULL;
		 F_AUDIO_LOG_ERROR("Only PCM encoding is supported");
		 return kNotFindAudioStream;
      }
      wav_header_.format_tag = stmp;

      fread(&stmp, 2, 1, wav_file_);
      stmp = le_short(stmp);

      if (stmp>2)
      {
         fclose(wav_file_);
		 wav_file_ = NULL;
		 F_AUDIO_LOG_ERROR("Only mono and (intensity) stereo supported");
		 return kNotFindAudioStream;
      }
      wav_header_.channels_count = stmp;


      fread(&itmp, 4, 1, wav_file_);
      itmp = le_int(itmp);

//      if (itmp != 8000 && itmp != 16000 && itmp != 11025 && itmp != 22050 && itmp != 32000 && itmp != 44100 && itmp != 48000)
//      {
//         fprintf (stderr, "Only 8 kHz (narrowband) and 16 kHz (wideband) supported (plus 11.025 kHz and 22.05 kHz, but your mileage may vary)\n");
//         return -1;
//      }
      wav_header_.samples_persecond = itmp;

      fread(&itmp, 4, 1, wav_file_);
      bpersec = le_int(itmp);
      wav_header_.bytes_persecond = bpersec;

      fread(&stmp, 2, 1, wav_file_);
      balign = le_short(stmp);
      wav_header_.block_align = balign;

      fread(&stmp, 2, 1, wav_file_);
      stmp = le_short(stmp);
      if (stmp!=16 && stmp!=8)
      {
         fclose(wav_file_);
		 wav_file_ = NULL;
		 F_AUDIO_LOG_ERROR("Only 8/16-bit linear supported");
		 return kNotFindAudioStream;
      }
      wav_header_.bits_persample = stmp;

      /*strange way of seeking, but it works even for pipes*/
      if (skip_bytes>0)
         for (i=0;i<skip_bytes;i++)
            fgetc(wav_file_);

      /*fseek(file, skip_bytes, SEEK_CUR);*/

      fread(ch, 1, 4, wav_file_);
      while (strcmp(ch, "data")!=0)
      {
         fread(&itmp, 4, 1, wav_file_);
         itmp = le_int(itmp);
         /*strange way of seeking, but it works even for pipes*/
         for (i=0;i<itmp;i++)
            fgetc(wav_file_);
         /*fseek(file, itmp, SEEK_CUR);*/
         fread(ch, 1, 4, wav_file_);
         if (feof(wav_file_))
         {
            fclose(wav_file_);
			 wav_file_ = NULL;
			 F_AUDIO_LOG_ERROR("Corrupted WAVE file: no \"data\"");
			 return kNotFindAudioStream;
         }
      }
      memcpy(wav_header_.data_chkid, ch, 4);

      /*Ignore this for now*/
      fread(&itmp, 4, 1, wav_file_);
      itmp = le_int(itmp);

      wav_header_.data_chkLen = itmp;

      frame_size_ = wav_header_.samples_persecond * 20 / 1000;
      buffer_size_ = wav_header_.block_align * frame_size_;

      F_AUDIO_LOG_INFO("file:%s,channels %d,bispersample %d,sample rate %d,data size %s",
    		  file_name,wav_header_.channels_count,wav_header_.bits_persample,
    		  wav_header_.samples_persecond,wav_header_.data_chkid);
    F_AUDIO_LOG_VERBOSE("end");
    return error;
}

int AudioReaderWav::GetFrame(short* data, int& sample_count, int &is_finished) {
    F_AUDIO_LOG_VERBOSE("begin");

    //∂¡»°“ª÷° ˝æ›
    int error = DecodeAudioFrame(data, &sample_count, &is_finished);

    F_AUDIO_LOG_VERBOSE("end");
    return error;
}

int AudioReaderWav::CloseInputFile() {
    F_AUDIO_LOG_VERBOSE("begin");

    //πÿ±’Œƒº˛
    fclose(wav_file_);
    wav_file_  = NULL;

    F_AUDIO_LOG_VERBOSE("end");
    return kNoError;
}

int AudioReaderWav::OpenInputAudioFile(const char* filename) {

	// ¥Úø™Œƒº˛
	wav_file_ = fopen(filename, "rb");
	if(wav_file_ == NULL) {
		F_AUDIO_LOG_ERROR("Could not open audio file %s", filename);
		return kCannotOpenInputFile;
	}
	return kNoError;
}

int AudioReaderWav::DecodeAudioFrame(void* data, int *datapresent, int *finished) {
	if(feof(wav_file_)){
		*finished = 1;
		return kFileEnd;
	}
	*finished = 0;
	//∂¡≥ˆ“ª÷° ˝æ›
	*datapresent = fread(data, wav_header_.block_align, frame_size_, wav_file_);

    return kNoError;
}

